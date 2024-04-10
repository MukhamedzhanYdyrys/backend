import re
import requests
import phonenumbers
from datetime import date, datetime
from typing import Optional
from dateutil.relativedelta import relativedelta

from django.contrib.auth import password_validation
from django.contrib.auth.hashers import make_password
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from auth_user.models import PendingUser, OtpToken, User, UserTypes
from auth_user.serializers import UserModelSerializer
from common.exceptions import DepartmentNotFoundException, PhoneNumberExistsException, EmailExistsException, \
    InvalidOtpTokenException, PasswordTooSimpleException, PhoneNumberInvalidException, InactiveUserException
from common.dates import server_now
from companies.models import Department, Role
from companies.services import calculate_late_minutes
from config import settings
from timesheet.models import TimeSheet, TimeSheetChoices


def create_pending_user(validated_data: dict) -> PendingUser:
    otp_token = validate_user_registration_data(validated_data)

    department: Department = validated_data['department']
    if not department or department.company != otp_token.company:
        raise DepartmentNotFoundException()

    try:
        password_validation.validate_password(validated_data['password'])
    except password_validation.ValidationError as e:
        raise PasswordTooSimpleException()

    pending_user = PendingUser.objects.create(
        email=validated_data['email'],
        first_name=validated_data['first_name'],
        last_name=validated_data['last_name'],
        middle_name=validated_data.get('middle_name', ''),
        phone_number=otp_token.phone_number,
        department=department,
        password_hash=make_password(validated_data['password']),
        avatar=validated_data.get('avatar'),
    )

    otp_token.delete()

    return pending_user


def validate_user_registration_data(validated_data: dict) -> OtpToken:
    otp_token = OtpToken.objects.filter(token=validated_data['otp_token'], created_at__gt=OtpToken.exp_date()).first()
    if not otp_token or not otp_token.verified:
        raise InvalidOtpTokenException()

    phone_number_clean = otp_token.phone_number
    if User.objects.filter(phone_number=phone_number_clean).exists():
        raise PhoneNumberExistsException()

    if User.objects.filter(email__iexact=validated_data['email']).exists():
        raise EmailExistsException()

    return otp_token


def clean_phone_number(phone_number: str) -> str:
    try:
        phone_number = phonenumbers.parse(phone_number)
    except phonenumbers.NumberParseException:
        raise PhoneNumberInvalidException()

    return f'+{phone_number.country_code}{phone_number.national_number}'


def send_sms(phone_number: str, sms_text: str):
    if '127.0.0.1' in settings.CURRENT_SITE:
        print(f'SMS is not sent: {sms_text}')
        return

    url = f"http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.ISMS_LOGIN}&password={settings.ISMS_PASSWORD}&recipient={phone_number}&messagetype=SMS:TEXT&originator=KiT_Notify&messagedata={sms_text}"
    response = requests.request('GET', url)

    if response.status_code != 200:
        raise Exception(f'SMS not sent: {response.text}')


def is_valid_password(new_password: str):

    if len(new_password) < 8:
        raise serializers.ValidationError(_("Пароль должен содержать минимум 8 символов"), code='less-then-8-digits')

    if not re.search("[0-9]", new_password):
        raise serializers.ValidationError(_("Пароль должен содержать минимум 1 цифры"), code='min-1-digits')

    if not re.search("[A-Z]", new_password):
        raise serializers.ValidationError(_("Пароль должен содержать минимум 1 заглавную букву"), code='min-1-upper-letter')


def get_additional_user_info(user) -> Optional[dict]:

    if not user.is_active:
        raise InactiveUserException()

    role = Role.objects.filter(user=user).first()

    user_data = UserModelSerializer(user).data
    user_data['role'] = get_user_role(user)
    user_data['role_title'] = role.title if role else None
    user_data['role_id'] = role.id if role else None
    user_data['departament'] = role.department_id if role else None

    return user_data


def get_user_role(user: User) -> str:
    if user.is_anonymous:
        return 'no_role'
    if user.is_superuser:
        return 'superuser'

    return str(UserTypes(user.type).label)


def validate_and_clean_phone_number(current_user, phone_number_raw: str):
    phone_number_clean = clean_phone_number(phone_number_raw)
    existing_user = User.objects.filter(phone_number=phone_number_clean).first()
    if existing_user and existing_user != current_user:
        raise PhoneNumberExistsException()

    return phone_number_clean


def get_role_month_overview(role: Role) -> dict:
    on_time = 0
    absent = 0
    late_minutes = 0.0

    if role:
        today = date.today()
        month_beginning = date(today.year, today.month, 1)

        on_time = TimeSheet.objects.filter(
            role=role, 
            status__in=[TimeSheetChoices.ON_TIME, TimeSheetChoices.LATE], 
            day__gte=month_beginning
        ).count()

        absent = TimeSheet.objects.filter(
            role=role,
            status=TimeSheetChoices.ABSENT,
            day__gte=month_beginning
        ).count()

        late_minutes = calculate_late_minutes(
            role=role,
            day__gte=month_beginning
        )

    return {
        'on_time': on_time,
        'absent': absent,
        'late_minutes': late_minutes,
    }


def calculate_score_for_current_month(role: Role):
    now = server_now()

    first_date_of_month = datetime(now.year, now.month, 1, tzinfo=now.tzinfo)
    last_date_of_month = first_date_of_month + relativedelta(months=1)

    points = role.scores \
        .filter(created_at__range=[first_date_of_month, last_date_of_month]) \
        .values_list('points', flat=True)

    score = sum(point for point in points) + 100
    return score


def update_user_profile(user, serializer):
    data = serializer.validated_data
    serializer = UserModelSerializer(user, data=data, partial=True)
    serializer.is_valid(raise_exception=True)
    serializer.save()

    return serializer.data, 200


def change_password(user: User, validated_data: dict) -> None:
    if user.check_password(validated_data.get('old_password')):
        user.set_password(validated_data.get('new_password'))
        user.save(update_fields=['password'])
    else:
        raise serializers.ValidationError(_('Неправильный старый пароль'), code='incorrect_old')