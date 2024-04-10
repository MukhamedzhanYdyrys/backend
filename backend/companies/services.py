from datetime import datetime
from typing import Tuple

from django.db import IntegrityError
from django.db.models import Prefetch, F, Count
from django.db.transaction import atomic
from django.db.models.query import QuerySet

from auth_user.models import PendingUser, User, UserTypes
from common.dates import timezone_from_str
from common.exceptions import EmailExistsException, CompanyAlreadyExists, UserAlreadyExists
from companies.models import Role, Department, RoleChoices, Company, Zone
from config import settings
from timesheet.models import TimeSheet, TimeSheetChoices, EmployeeSchedule, DepartmentSchedule
from scores.models import Reason, ReasonType
from scores.utils import GetScoreForRole


def calculate_late_minutes(**kwargs):
    late_sheets = TimeSheet.objects.filter(
        status__in=[TimeSheetChoices.LATE, TimeSheetChoices.BEG_OFF], **kwargs
    ).exclude(check_in=None)

    late_minutes = 0.0

    for sheet in late_sheets:
        if sheet.time_from and sheet.check_in:
            tz = timezone_from_str(sheet.timezone)
            required_time = datetime.combine(sheet.check_in.date(), sheet.time_from, tzinfo=tz)
            naive_date = sheet.check_in.astimezone(tz)
            late_minutes += max(0.0, (naive_date - required_time).total_seconds() / 60.0)

    return late_minutes


def get_employee_list():
    qs = Role.objects.filter(user__is_active=True)

    # TODO: DELETE GetScoreForRole?
    qs = qs.annotate(
        score=GetScoreForRole('companies_role.id')
    ).select_related(
        'user',
        'department'
    ).prefetch_related(
        Prefetch(
            'employee_schedules',
            queryset=EmployeeSchedule.objects.order_by().select_related(
                'role', 'role__department'
            ).annotate(
                timezone=F('role__department__timezone')
            ),
            to_attr='schedules'
        )
    ).distinct()

    return qs


@atomic
def create_employee(data: dict) -> Role:
    title = data.pop('title')
    grade = data.pop('grade')
    department_id = data.pop('department_id')
    schedules = data.pop('schedules')
    zones = data.pop('zones')
    in_zone = data.pop('in_zone')
    checkout_any_time = data.pop('checkout_any_time')
    checkout_time = data.pop('checkout_time')
    pending_user_id = data.pop('pending_user_id', None)

    department = Department.objects.get(id=department_id)
    data['selected_company_id'] = department.company_id

    pending_user = PendingUser.objects.filter(id=pending_user_id).first() if pending_user_id else None
    if pending_user:
        data['password'] = pending_user.password_hash
        if not data.get('avatar'):
            data['avatar'] = pending_user.avatar
        pending_user.delete()

    data['type'] = UserTypes.HR if department.is_hr else UserTypes.EMPLOYEE
    data['owner'] = department.company.owner

    user = User.objects.create_user(**data)

    role = Role.objects.create(
        company=department.company,
        department=department,
        role=RoleChoices.HR if department.is_hr else RoleChoices.EMPLOYEE,  # TODO: DELETE
        user=user,
        title=title,
        grade=grade,
        in_zone=in_zone,
        checkout_any_time=checkout_any_time,
        checkout_time=checkout_time,
    )

    role.zones.set(zones)
    create_employee_schedules(role, schedules)
    return role


def create_employee_schedules(role: Role, schedules: list) -> None:
    new_schedules = [
        EmployeeSchedule(
            role=role,
            week_day=schedule['week_day'],
            time_from=schedule['time_from'],
            time_to=schedule['time_to'],
            is_night_shift=schedule['is_night_shift']
        ) for schedule in schedules]
    EmployeeSchedule.objects.bulk_create(new_schedules)


@atomic
def update_employee(request, role: Role, data: dict) -> None:
    role_data = {
        'title': data.pop('title'),
        'grade': data.pop('grade'),
        'department_id': data.pop('department_id'),
        'in_zone': data.pop('in_zone'),
        'checkout_any_time': data.pop('checkout_any_time'),
        'checkout_time': data.pop('checkout_time')
    }
    Role.objects.filter(id=role.id).update(**role_data)

    zones = data.pop('zones')
    role.zones.set(zones)

    EmployeeSchedule.objects.filter(role=role).delete()

    schedules = data.pop('schedules', [])

    if schedules:
        create_employee_schedules(role, schedules)

    user = role.user

    email = data.get('email', '').strip().lower()
    data['email'] = email

    if email and email != user.email.lower():
        if User.objects.filter(email__iexact=email).exists():
            raise EmailExistsException()

    for key, value in data.items():
        setattr(user, key, value)

    user.save(update_fields=data.keys())


def get_departments_qs() -> QuerySet[Department]:
    return Department.objects.filter(
        company__is_deleted=False
    ).annotate(
        employees_count=Count('roles')
    ).prefetch_related(
        Prefetch(
            'department_schedules',
            queryset=DepartmentSchedule.objects.order_by().select_related(
                'department',
            ).annotate(
                timezone=F('department__timezone')
            ),
            to_attr='schedules'
        )
    ).order_by('id')


@atomic
def create_department(company: Company, data: dict) -> Department:
    department = Department.objects.create(
        name=data.pop('name'),
        company=company,
        timezone=data.pop('timezone', settings.TIME_ZONE),
        start_inaccuracy=data.pop('start_inaccuracy', 0)
    )

    update_department(department, data)

    return department


@atomic
def update_department(instance: Department, data) -> None:
    DepartmentSchedule.objects.filter(department=instance).delete()
    bulk_create_department_schedules(instance, data.pop('schedules'))

    zones = data.pop('zones')
    instance.zones.set(zones)

    head_role_id = data.get('head_of_department_id')
    head = Role.objects.get(id=head_role_id) if head_role_id else None

    if head and head.department != instance:
        head.role = RoleChoices.HR if instance.is_hr else RoleChoices.EMPLOYEE
        head.department = instance
        head.save(update_fields=['role', 'department'])

        head.user.type = UserTypes.HR if instance.is_hr else UserTypes.EMPLOYEE
        head.user.save(update_fields=['type'])

    for key, value in data.items():
        setattr(instance, key, value)

    instance.save()


def bulk_create_department_schedules(department: Department, schedules: list) -> None:
    new_schedules = [
        DepartmentSchedule(
            department=department,
            week_day=schedule['week_day'],
            time_from=schedule['time_from'],
            time_to=schedule['time_to'],
        ) for schedule in schedules]
    DepartmentSchedule.objects.bulk_create(new_schedules)


def delete_head_of_department_role(instance: Department) -> None:
    if instance.head_of_department is not None:
        instance.head_of_department.delete()


def check_email_existence(email):
    if User.objects.filter(email=email).exists():
        raise EmailExistsException()


def check_company_existence(company_name):
    if Company.objects.filter(name=company_name).exists():
        raise CompanyAlreadyExists()


@atomic
def create_company(data: dict) -> Company:
    company, hr_department = create_and_prepare_company(data)
    owner, password = create_owner(data, company)

    company.owner = owner
    company.save(update_fields=['owner'])

    return company


def random_invite_code():
    import random
    import string
    return ''.join(random.choice(string.digits) for _ in range(6))


def __generate_invite_code():
    attempt = 0
    while attempt < 10:
        attempt += 1
        invite_code = random_invite_code()
        if not Company.objects.filter(invite_code=invite_code).exists():
            return invite_code

    raise Exception('Cannot generate invite code')


@atomic()
def create_and_prepare_company(data: dict) -> Tuple[Company, Department]:
    name = data.get('company_name').strip()
    owner = data.get('owner')
    if owner and Company.objects.filter(name__iexact=name, owner=owner).exists():
        raise CompanyAlreadyExists()

    company = Company.objects.create(
        name=name,
        owner=owner,
        years_of_work=data['years_of_work'],
        max_employees_qty=data['max_employees_qty'],
        invite_code=__generate_invite_code(),
    )
    hr_department = create_hr_department(company, data.get('timezone'))
    create_score_reasons(company)

    return company, hr_department


def create_owner(data: dict, company: Company) -> Tuple[User, str]:
    from auth_user.services import validate_user_registration_data
    otp_token = validate_user_registration_data(data)
    try:
        owner = User.objects.create(
            owner=None,
            type=UserTypes.OWNER,
            email=data['email'],
            first_name=data['first_name'],
            last_name=data['last_name'],
            middle_name=data['middle_name'],
            phone_number=otp_token.phone_number,
            selected_company=company,
        )
    except IntegrityError:
        raise UserAlreadyExists()
    password = data['password']
    owner.set_password(password)
    owner.save(update_fields=['password'])
    return owner, password


def create_hr_department(company: Company, timezone: str = None):
    hr_department = Department.objects.create(
        name='HR',
        is_hr=True,
        company=company,
        timezone=timezone or settings.TIME_ZONE,
    )
    department_schedule = [
        DepartmentSchedule(department=hr_department, week_day=i, time_from='09:00', time_to='18:00')
        for i in range(0, 5)
    ]
    DepartmentSchedule.objects.bulk_create(department_schedule)

    return hr_department


def create_score_reasons(company: Company):
    reasons = [
        Reason(type=ReasonType.LATE_CHECK_IN, score=-10, company=company),
        Reason(type=ReasonType.LATE_CHECK_OUT, score=-10, company=company),
        Reason(type=ReasonType.ABSENT, score=-15, company=company),
        Reason(type=ReasonType.TRELLO_MISSED_DEADLINE_EASY, score=-2, company=company),
        Reason(type=ReasonType.TRELLO_MISSED_DEADLINE_MEDIUM, score=-5, company=company),
        Reason(type=ReasonType.TRELLO_MISSED_DEADLINE_HARD, score=-10, company=company),
        Reason(type=ReasonType.TRELLO_COMPLETED_EASY, score=1, company=company),
        Reason(type=ReasonType.TRELLO_COMPLETED_MEDIUM, score=3, company=company),
        Reason(type=ReasonType.TRELLO_COMPLETED_HARD, score=5, company=company),
    ]
    Reason.objects.bulk_create(reasons)


def get_zones_qs():
    return Zone.objects.order_by('-id').prefetch_related(
        Prefetch(
            'employees',
            queryset=Role.objects.select_related('user')
        )
    )