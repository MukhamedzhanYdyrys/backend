import geopy.distance
from datetime import date, timedelta, datetime
from typing import Optional

from django.db.transaction import atomic
from django.db.models import Sum
from django.utils.translation import gettext_lazy as _

from companies.models import Role, Department
from common.dates import server_now, get_utc_offset_string, timezone_from_str, \
    combine_to_server_datetime
from common.exceptions import CheckInCoordinatesException, CheckInTwiceException, \
    TookOffException, DayOffException, EmployeeTooFarFromDepartment, CheckInRequiredException, \
    CheckOutTwiceException, CheckOutExpiredException, TooEarlyCheckoutException, CustomResponseException
from config import settings
from checklist.services import complete_checklists_for_user
from timesheet.models import AbstractSchedule, EmployeeSchedule, TimeSheet, \
    TimeSheetChoices
from timesheet.serializers import TimeSheetModelSerializer
from scores.models import Score, Reason, ReasonType

class CachedSchedule:
    def __init__(self, role: Role):
        self.role = role
        self.days_of_week = None
        self.schedules = EmployeeSchedule.objects.filter(role=role)

    def get_schedule_for_day(self, day: date) -> AbstractSchedule | None:
        if self.days_of_week is None:
            self.days_of_week = {}
            for schedule in self.schedules:
                self.days_of_week[schedule.week_day] = schedule

        return self.days_of_week.get(day.weekday())


def get_schedule_for_role(role: Role, day: date) -> AbstractSchedule | None:
    return CachedSchedule(role).get_schedule_for_day(day)


def get_missed_timesheet(cached_schedule: CachedSchedule, day: date):
    role = cached_schedule.role
    workday_schedule = cached_schedule.get_schedule_for_day(day)
    day_str = day.strftime('%Y-%m-%d')

    if day <= server_now().date():
        if day < role.created_at.date():
            return fake_not_registered_timesheet(role, day)
        if workday_schedule:
            return create_absent_timesheet(day, workday_schedule)
        return create_day_off_timesheet(role, day_str)

    if workday_schedule:
        return fake_future_day_timesheet(role, day_str, workday_schedule)

    return fake_future_day_off_timesheet(role, day_str)


def fake_not_registered_timesheet(role: Role, day: date) -> TimeSheetModelSerializer:
    tz = role.department.timezone if role.department else settings.TIME_ZONE

    timesheet = TimeSheet()
    timesheet.timezone = get_utc_offset_string(tz)
    timesheet.role = role
    timesheet.status = TimeSheetChoices.NONE
    timesheet.day = day
    timesheet.is_night_shift = False
    return TimeSheetModelSerializer(timesheet).data


def create_absent_timesheet(day: date, schedule: AbstractSchedule):
    role = schedule.role

    status_timesheet = TimeSheetChoices.ABSENT

    # todo: check time_to as well
    if day >= server_now().date():
        status_timesheet = TimeSheetChoices.FUTURE_DAY

    tz = role.department.timezone if role.department else settings.TIME_ZONE
    timesheet, created = TimeSheet.objects.update_or_create(
        role=role,
        day=day,
        defaults={
            'timezone': get_utc_offset_string(tz),
            'status': status_timesheet,
            'time_from': schedule.time_from,
            'time_to': schedule.time_to,
            'is_night_shift': schedule.is_night_shift,
            'is_remote': schedule.is_remote
        }
    )
    return TimeSheetModelSerializer(timesheet).data


def create_day_off_timesheet(role: Role, day_str: str):
    tz = role.department.timezone if role.department else settings.TIME_ZONE
    timesheet, created = TimeSheet.objects.update_or_create(
        role=role,
        day=day_str,
        defaults={
            'timezone': get_utc_offset_string(tz),
            'status': TimeSheetChoices.DAY_OFF,
        }
    )
    return TimeSheetModelSerializer(timesheet).data


def fake_future_day_timesheet(role: Role, day_str: str, schedule: AbstractSchedule):
    tz = role.department.timezone if role.department else settings.TIME_ZONE

    timesheet = TimeSheet()
    timesheet.timezone = get_utc_offset_string(tz)
    timesheet.role = role
    timesheet.status = TimeSheetChoices.FUTURE_DAY
    timesheet.day = day_str
    timesheet.time_from = schedule.time_from
    timesheet.time_to = schedule.time_to
    timesheet.is_night_shift = schedule.is_night_shift
    timesheet.is_remote = schedule.is_remote
    return TimeSheetModelSerializer(timesheet).data


def fake_future_day_off_timesheet(role: Role, day_str: str):
    tz = role.department.timezone if role.department else settings.TIME_ZONE

    timesheet = TimeSheet()
    timesheet.timezone = get_utc_offset_string(tz)
    timesheet.role = role
    timesheet.status = TimeSheetChoices.DAY_OFF
    timesheet.day = day_str
    timesheet.is_night_shift = False
    return TimeSheetModelSerializer(timesheet).data


@atomic
def perform_check_in(timesheet: TimeSheet, data: dict) -> None:
    role: Role = timesheet.role
    department: Department = role.department

    if role.in_zone:
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        if not latitude or not longitude:
            raise CheckInCoordinatesException()
        check_distance(role, latitude, longitude)

    if timesheet.check_in:
        raise CheckInTwiceException()

    if timesheet.status == TimeSheetChoices.BEG_OFF:
        raise TookOffException()

    tz = timezone_from_str(department.timezone)
    now_local = datetime.now(tz)

    schedule = get_schedule_for_role(role, now_local.date())
    if not schedule:
        raise DayOffException()

    check_in_datetime = datetime.combine(now_local.date(), schedule.time_from, tz)
    check_in_expired = check_in_datetime + timedelta(minutes=(department.start_inaccuracy + 1))

    timesheet_status = TimeSheetChoices.ON_TIME
    if now_local > check_in_expired:
        timesheet_status = TimeSheetChoices.LATE
        apply_penalty(role, ReasonType.LATE_CHECK_IN)

    timesheet.check_in = now_local
    timesheet.check_out = None
    timesheet.status = timesheet_status
    timesheet.time_from = schedule.time_from
    timesheet.time_to = schedule.time_to
    timesheet.is_night_shift = schedule.is_night_shift
    timesheet.is_remote = schedule.is_remote
    timesheet.timezone = get_utc_offset_string(department.timezone)
    timesheet.file = data.get('file', None)
    timesheet.comment = data.get('comment', '')
    timesheet.device_id = data.get('device_id', '')
    timesheet.save()


def __is_inside_zones(zones, latitude: float, longitude: float) -> bool:
    for zone in zones:
        distance = geopy.distance.geodesic((latitude, longitude), (zone.latitude, zone.longitude)).m
        if distance <= zone.radius:
            return True
    return False


def check_distance(role: Role, latitude: float, longitude: float) -> None:
    user_zones = role.zones.all()
    if __is_inside_zones(user_zones, latitude, longitude):
        return

    department_zones = role.department.zones.all()
    if __is_inside_zones(department_zones, latitude, longitude):
        return

    if user_zones or department_zones:
        raise EmployeeTooFarFromDepartment()


def apply_penalty(role: Role, reason_type: ReasonType):
    reason = Reason.objects.filter(type=reason_type, company=role.company).first()
    if reason and reason.score != 0:
        Score.objects.create(
            role=role,
            reason_type=reason_type,
            points=reason.score,
        )


@atomic
def perform_check_out(timesheet: TimeSheet, data: dict):
    if not timesheet.check_in:
        raise CheckInRequiredException()

    if timesheet.check_out:
        raise CheckOutTwiceException()

    now = server_now()
    is_check_out_expired = __is_checkout_expired(timesheet, now)

    check_out: datetime = data.get('custom_date')
    if not check_out:
        if is_check_out_expired:
            raise CheckOutExpiredException()
        check_out = now

    role: Role = timesheet.role

    __validate_check_out(
        role=role,
        timesheet=timesheet,
        latitude=data['latitude'],
        longitude=data['longitude'],
        check_out=check_out,
        now=now,
    )

    complete_checklists_for_user(timesheet.role.user, timesheet.day)

    if is_check_out_expired:
        apply_penalty(role, ReasonType.LATE_CHECK_OUT)

    timesheet.check_out = check_out
    timesheet.save(update_fields=['check_out'])

    check_in_device_id = timesheet.device_id
    check_out_device_id = data.get('device_id')

def __is_checkout_expired(timesheet: TimeSheet, now: datetime) -> bool:
    if timesheet.is_night_shift:
        time_to = combine_to_server_datetime(timesheet.day + timedelta(days=1), timesheet.time_to, timesheet.timezone)
    else:
        time_to = combine_to_server_datetime(timesheet.day, timesheet.time_to, timesheet.timezone)

    return time_to + timedelta(hours=6) < now


def __validate_check_out(role: Role, timesheet: TimeSheet, latitude: float, longitude: float, check_out: datetime,
                         now: datetime) -> None:
    in_zone_valid = True
    if role.in_zone:
        try:
            check_distance(role, latitude, longitude)
        except EmployeeTooFarFromDepartment as e:
            in_zone_valid = False

    schedule_valid = True
    if not role.checkout_any_time:
        try:
            check_if_checkout_is_possible(timesheet, check_out)
        except TooEarlyCheckoutException:
            schedule_valid = False

    if in_zone_valid and schedule_valid:
        return

    raise CustomResponseException(data={
        'code': 'checkout-validation',
        'message': _('Вы не можете завершить рабочий день'),
        'fields': [
            {'name': 'zone', 'label': _('Зона'), 'valid': in_zone_valid},
            {'name': 'schedule', 'label': _('Расписание'), 'valid': schedule_valid},
        ],
    })


def check_if_checkout_is_possible(timesheet: TimeSheet, check_out: datetime):
    time_to_date = timesheet.day

    if timesheet.is_night_shift:
        time_to_date += timedelta(days=1)

    now_time = datetime.combine(time_to_date, timesheet.time_to, tzinfo=check_out.tzinfo)

    time_diff = now_time - check_out
    if time_diff > timedelta(minutes=timesheet.role.checkout_time):
        raise TooEarlyCheckoutException()


def get_score_for_month(role: Role, year: int, month: int) -> Optional[int]:
    month_last_day = (date(year, month, 1) + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    return get_score_for_day(role, month_last_day)


def get_score_for_day(role: Role, day: date) -> Optional[int]:
    if (day.year * 12 + day.month) < (role.created_at.year * 12 + role.created_at.month):
        return None

    day_start = datetime(day.year, day.month, 1)
    day_end = datetime(day.year, day.month, day.day) + timedelta(days=1)
    score = Score.objects.filter(role=role, created_at__gt=day_start, created_at__lt=day_end) \
        .aggregate(Sum("points"))

    return 100 + (score['points__sum'] or 0)
