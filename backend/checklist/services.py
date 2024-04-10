from datetime import date, datetime
from typing import Optional

from django.db.models import Q
from django.db.transaction import atomic
from django.shortcuts import get_object_or_404
from django.utils.translation import gettext_lazy as _
from rest_framework import status
from rest_framework import serializers

from auth_user.models import User, UserTypes
from companies.models import Role, Company
from common.dates import timezone_from_str, is_valid_timezone
from common.exceptions import ChecklistAlreadyCompletedException, ChecklistAssignNotCorrectException, \
    ChecklistNotForThisDayException, TaskNotFoundException, TaskNotBelongChecklistException, \
    UnknownErrorException, BoundPointChecklistException, CompanyOtherEmployeeExists
from checklist.models import ChecklistAssign, ChecklistComplete, ChecklistCompleteStatuses, \
    ChecklistAssignTypes, Checklist, TaskGroup, ChecklistSchedule, Task, TaskCheck, TaskFile
from scores.models import ReasonType, Score
from timesheet.models import TimeSheet, TimeSheetChoices


def checklist_assigns_for_user(user, day: date):
    query = ChecklistAssign.objects \
        .filter(user=user) \
        .filter(Q(checklist__schedules__week_day=day.weekday(), checklist__start_date=None) |
                Q(checklist__schedules__week_day=day.weekday(), checklist__start_date__lte=day) |
                Q(checklist__completes__date=day)) \
        .distinct()

    return query.prefetch_related('checklist')


def complete_checklists_for_user(user, day: date, beg_off=False):
    assigns = checklist_assigns_for_user(user, day)
    for assign in assigns:
        complete_checklist(assign, ChecklistCompleteStatuses.NOT_COMPLETED, day, beg_off=beg_off)


def complete_checklist(assign: ChecklistAssign, status: ChecklistCompleteStatuses, day: date, beg_off=False):

    checklist: Checklist = assign.checklist

    # Ignore if the checklist is already completed
    if ChecklistComplete.objects.filter(checklist=checklist, user=assign.user, date=day).exists():
        return False

    points = 0
    reason_type = ReasonType.CUSTOM
    if assign.type == ChecklistAssignTypes.EXECUTOR:
        if status == ChecklistCompleteStatuses.COMPLETED_ON_TIME:
            points = checklist.executor_reward
            reason_type = ReasonType.CHECKLIST_EXECUTOR_REWARD
        elif status == ChecklistCompleteStatuses.COMPLETED_LATE:
            points = -1 * checklist.executor_penalty_late
            reason_type = ReasonType.CHECKLIST_EXECUTOR_PENALTY_LATE
        elif status == ChecklistCompleteStatuses.NOT_COMPLETED:
            points = -1 * checklist.executor_penalty_not_completed
            reason_type = ReasonType.CHECKLIST_EXECUTOR_PENALTY_NOT_COMPLETED

    elif assign.type == ChecklistAssignTypes.INSPECTOR:
        if status == ChecklistCompleteStatuses.COMPLETED_ON_TIME:
            points = checklist.inspector_reward
            reason_type = ReasonType.CHECKLIST_INSPECTOR_REWARD
        elif status == ChecklistCompleteStatuses.COMPLETED_LATE:
            points = -1 * checklist.inspector_penalty_late
            reason_type = ReasonType.CHECKLIST_INSPECTOR_PENALTY_LATE
        elif status == ChecklistCompleteStatuses.NOT_COMPLETED:
            points = -1 * checklist.inspector_penalty_not_completed
            reason_type = ReasonType.CHECKLIST_INSPECTOR_PENALTY_NOT_COMPLETED

    has_checkboxes = TaskGroup.objects.filter(checklist=assign.checklist, checkbox=True).exists()
    if not has_checkboxes:
        status = ChecklistCompleteStatuses.INFORMATIVE
        points = 0

    if beg_off:
        fail_deadline = False
        checklist_schedule = ChecklistSchedule.objects.filter(checklist=checklist, week_day=day.weekday()).first()
        if checklist_schedule and checklist_schedule.time_to:
            tz = timezone_from_str(checklist.timezone)
            deadline = datetime.combine(day, checklist_schedule.time_to, tzinfo=tz)
            now = datetime.now(tz)
            if deadline < now:
                fail_deadline = True

        if not fail_deadline:
            status = ChecklistCompleteStatuses.BEG_OFF
            points = 0

    # role is none for owners
    role = Role.objects.filter(user=assign.user).first()

    if role and status == ChecklistCompleteStatuses.NOT_COMPLETED:
        timesheet = TimeSheet.objects.filter(role_id=role.id, day=day).first()
        if timesheet and timesheet.status in [TimeSheetChoices.ON_VACATION, TimeSheetChoices.BEG_OFF]:
            points = 0

    if role is None:
        points = 0

    ChecklistComplete.objects.create(
        checklist=checklist,
        user_id=assign.user_id,
        date=day,
        status=status,
        points=points,
    )

    if role and status != ChecklistCompleteStatuses.INFORMATIVE:
        Score.objects.create(
            role_id=role.id,
            points=points,
            reason_type=reason_type,
        )

    return True


def control_checklists(user: User, day: date, data: dict) -> status:
    checklist_id = data.get('checklist_id')
    task_id = data.get('task_id')
    action = data.get('action')

    checklist = get_object_or_404(Checklist, id=checklist_id)

    assign = ChecklistAssign.objects.filter(user=user, checklist=checklist).first()
    if not assign:
        raise ChecklistAssignNotCorrectException()

    if action == 'complete':
        schedule = ChecklistSchedule.objects.filter(checklist=checklist, week_day=day.weekday()).first()
        if not schedule:
            raise ChecklistNotForThisDayException()

        tz = timezone_from_str(checklist.timezone)
        local_now = datetime.now(tz)

        is_late = schedule.time_to and schedule.time_to < local_now.time()
        stat = ChecklistCompleteStatuses.COMPLETED_LATE if is_late else ChecklistCompleteStatuses.COMPLETED_ON_TIME

        created = complete_checklist(assign, stat, day)
        if created:
            return status.HTTP_201_CREATED

        raise ChecklistAlreadyCompletedException()

    task = Task.objects.filter(id=task_id).first() if task_id else None
    if not task:
        raise TaskNotFoundException()

    if task.group.checklist != checklist:
        raise TaskNotBelongChecklistException()

    if action == 'check':
        item, created = TaskCheck.objects.get_or_create(user=user, task=task, date=day)
        return status.HTTP_201_CREATED if created else status.HTTP_200_OK

    if action == 'uncheck':
        deleted, num_rows = TaskCheck.objects.filter(user=user, task=task, date=day).delete()
        return status.HTTP_201_CREATED if deleted else status.HTTP_200_OK

    raise UnknownErrorException()


atomic
def update_checklist(checklist: Optional[Checklist], request):
    data: dict = request.data
    groups = data.get('groups', [])
    schedules = data.get('schedules', [])
    executors = data.get('executors', [])
    inspectors = data.get('inspectors', [])

    # TODO: check that executors, inspectors and department are in the same company
    company: Company = request.user.selected_company

    if not checklist:
        checklist = Checklist()
        checklist.company = company

    checklist.name = data.get('name', '').strip()
    checklist.start_date = data.get('start_date')
    if not len(checklist.name) or not checklist.start_date:
        raise serializers.ValidationError(_('Пожалуйста, заполните все поля'))

    checklist.timezone = data.get('timezone')
    if not checklist.timezone or not is_valid_timezone(checklist.timezone):
        raise serializers.ValidationError(_('Неправильный часовой пояс'))

    checklist.department_id = data.get('department')

    checklist.executor_reward = parse_points(data.get('executor_reward'))
    checklist.executor_penalty_late = parse_points(data.get('executor_penalty_late'))
    checklist.executor_penalty_not_completed = parse_points(data.get('executor_penalty_not_completed'))
    checklist.inspector_reward = parse_points(data.get('inspector_reward'))
    checklist.inspector_penalty_late = parse_points(data.get('inspector_penalty_late'))
    checklist.inspector_penalty_not_completed = parse_points(data.get('inspector_penalty_not_completed'))
    checklist.save()

    assign_ids = []
    for executor in executors:
        if company not in user_companies(executor):
            raise CompanyOtherEmployeeExists()

        assign, created = ChecklistAssign.objects.get_or_create(
            checklist=checklist, user_id=executor, type=ChecklistAssignTypes.EXECUTOR
        )
        assign_ids.append(assign.pk)
    for inspector in inspectors:
        if company not in user_companies(inspector):
            raise CompanyOtherEmployeeExists()

        assign, created = ChecklistAssign.objects.get_or_create(
            checklist=checklist, user_id=inspector, type=ChecklistAssignTypes.INSPECTOR
        )
        assign_ids.append(assign.pk)
    ChecklistAssign.objects.filter(checklist=checklist).exclude(pk__in=assign_ids).delete()

    ChecklistSchedule.objects.filter(checklist=checklist).delete()
    for schedule_info in schedules:
        schedule = ChecklistSchedule()
        schedule.checklist = checklist
        schedule.week_day = schedule_info['week_day']

        t0_str = schedule_info.get('time_from')
        t1_str = schedule_info.get('time_to')
        if t0_str and t1_str:
            t0 = datetime.strptime(t0_str, '%H:%M')
            t1 = datetime.strptime(t1_str, '%H:%M')
            if abs((t1 - t0).seconds) / 60 < 15:
                raise serializers.ValidationError(_('Минимальный временной интервал - 15 минут.'))
            schedule.time_from = t0.time()
            schedule.time_to = t1.time()

        schedule.save()

    if not groups:
        raise serializers.ValidationError(_('Нельзя создавать чек лист без группы'))

    group_ids = []
    for group_info in groups:
        group_id = group_info.get('id')
        group = TaskGroup.objects.get(pk=group_id, checklist=checklist) if group_id else TaskGroup()
        group.name = group_info.get('name', '').strip()
        if not len(group.name):
            raise serializers.ValidationError(_('Пожалуйста, заполните все поля'))

        group.checkbox = group_info.get('checkbox', False)

        group.checklist = checklist
        group.save()
        group_ids.append(group.id)

        task_ids = []
        tasks = group_info.get('tasks', [])
        if len(tasks) == 0:
            raise serializers.ValidationError(_('Группа задач не может быть пустой'))

        for task_info in tasks:
            task_id = task_info.get('id')
            task = Task.objects.get(pk=task_id, group=group) if task_id else Task()
            task.name = task_info.get('name', '').strip()
            if not len(task.name):
                raise serializers.ValidationError(_('Пожалуйста, заполните все поля'))

            task.group = group
            task.save()
            task_ids.append(task.id)

            file_ids = task_info.get('files', [])
            for file_id in file_ids:
                TaskFile.objects.get_or_create(task=task, file_id=file_id)
            TaskFile.objects.filter(task=task).exclude(file_id__in=file_ids).delete()

        Task.objects.filter(group=group).exclude(pk__in=task_ids).delete()

    TaskGroup.objects.filter(checklist=checklist).exclude(pk__in=group_ids).delete()


def parse_points(point):
    max_point = max(0, int(point or 0))
    if max_point > 100:
        raise BoundPointChecklistException()
    else:
        return max_point


def user_companies(user: User) -> list:
    # TODO: pass only the User type
    if isinstance(user, int):
        user = User.objects.get(pk=user)

    role = Role.objects.filter(user=user).first()
    if role:
        return [role.company]

    if user.type == UserTypes.CO_OWNER:
        return list(Company.objects.filter(accesses__user=user))

    return list(Company.objects.filter(owner=user))