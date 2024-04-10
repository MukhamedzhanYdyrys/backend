from zoneinfo import ZoneInfo, ZoneInfoNotFoundError
import pytz
from django.utils.timezone import get_current_timezone
from datetime import datetime, date, time
from config import settings


def server_tz() -> pytz.timezone:
    return get_current_timezone()


def to_server_tz(dt: datetime) -> datetime:
    return dt.astimezone(server_tz())


def server_now() -> datetime:
    return datetime.now(server_tz())


def combine_to_server_datetime(d: date, t: time, tz_name: str) -> datetime:
    return datetime.combine(d, t, tzinfo=timezone_from_str(tz_name))


def is_valid_timezone(tz_name: str) -> bool:
    try:
        ZoneInfo(key=tz_name)
        return True
    except ZoneInfoNotFoundError:
        return False


def timezone_from_str(tz_name: str) -> ZoneInfo:
    try:
        return ZoneInfo(key=tz_name)
    except ZoneInfoNotFoundError:
        return ZoneInfo(settings.TIME_ZONE)


def get_utc_offset_string(tz_name: str) -> str:
    try:
        utc_offset = datetime.now(ZoneInfo(tz_name)).utcoffset()
        hours = utc_offset.days * 24 + utc_offset.seconds // 3600
        minutes = (utc_offset.seconds // 60) % 60
        utc_offset_str = '{0:+03d}:{1:02d}'.format(hours, minutes)
        return utc_offset_str

    except ZoneInfoNotFoundError:
        return '+06:00'
