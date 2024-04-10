import datetime

from django.core.exceptions import ObjectDoesNotExist
from django.utils.translation import gettext_lazy as _
from django.contrib.auth import password_validation
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from auth_user.models import PendingUser, User
from companies.models import Company, Role
from config import settings


class PendingUserSerializer(serializers.ModelSerializer):
    avatar = serializers.FileField(required=False)
    password = serializers.CharField(write_only=True, required=True)
    otp_token = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = PendingUser
        exclude = ['password_hash', 'created_at', 'updated_at', 'phone_number']


class SendSmsSerializer(serializers.Serializer):
    phone_number = serializers.CharField()
    action = serializers.ChoiceField(required=False, allow_null=True, choices=[
        'change_password', 'change_number', 'register_employee', 'register_owner',
    ])
    invite_code = serializers.CharField(required=False, allow_blank=True, allow_null=True)


class VerifySmsSerializer(serializers.Serializer):
    otp_token = serializers.CharField()
    code = serializers.CharField()


class SetPasswordViaSmsSerializer(serializers.Serializer):
    reset_token = serializers.CharField()
    new_password = serializers.CharField()


class TokenCredentialsSerializer(TokenObtainPairSerializer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not kwargs.get('data'):  # Just for Swagger
            self.fields['phone_number'] = serializers.CharField(required=False)
            self.fields['email'] = serializers.CharField(required=False)


class UserModelSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ('id', 'first_name', 'last_name', 'middle_name', 'email', 'phone_number', 'language', 'selected_company_id', 'created_at')
        read_only_fields = ('id', 'email', 'is_admin')


class UserProfileSerializer(serializers.Serializer):
    id = serializers.IntegerField(required=False, read_only=True)
    first_name = serializers.CharField(max_length=50)
    last_name = serializers.CharField(max_length=50)
    middle_name = serializers.CharField(max_length=50, allow_blank=True)
    phone_number = serializers.CharField()
    email = serializers.EmailField(required=False, read_only=True)
    avatar = serializers.ImageField(required=False, allow_null=True)
    language = serializers.CharField(required=False)
    role = serializers.SerializerMethodField(required=False)
    selected_company = serializers.PrimaryKeyRelatedField(queryset=Company.objects.only('id'), required=False)
    today_schedule = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()
    timesheet = serializers.SerializerMethodField()  # TODO: rename to month_overview

    def validate_phone_number(self, phone_number_raw: str):
        from auth_user.services import validate_and_clean_phone_number
        current_user = self.context['request'].user
        return validate_and_clean_phone_number(current_user, phone_number_raw)

    def get_timesheet(self, instance: User):
        from auth_user.services import get_role_month_overview
        try:
            role = instance.role
        except ObjectDoesNotExist:
            role = None
        return get_role_month_overview(role)

    def get_today_schedule(self, instance: User):
        try:
            schedules = instance.role.employee_schedules.filter(week_day=datetime.date.today().weekday())
            if schedules.exists():
                schedule = schedules.first()
                time_from = schedule.time_from.strftime('%H:%M')
                time_to = schedule.time_to.strftime('%H:%M')
                current_date = datetime.datetime.now().strftime('%Y.%m.%d')
                if schedule.time_to < schedule.time_from:
                    next_day = datetime.datetime.now() + datetime.timedelta(days=1)
                    next_day_str = next_day.strftime('%Y.%m.%d')
                    return f'{current_date} {time_from} - {next_day_str} {time_to}'
                return f'{current_date} {time_from} - {current_date} {time_to}'

        except ObjectDoesNotExist:
            pass
        return ''

    def get_role(self, instance: User):
        from auth_user.services import get_user_role
        role_name = get_user_role(instance)
        role = Role.objects.filter(user=instance).first()
        if not role:
            return {
                'role': role_name,
                'role_id': 0,
                'department_id': 0,
                'department_name': '',
            }

        zones = list(role.zones.all()) + list(role.department.zones.all())
        return {
            'role': role_name,
            'role_id': role.id,
            'department_id': role.department.id,
            'department_name': role.department.name,
            'title': role.title,
            'grade': role.grade,
            'in_zone': role.in_zone,
            'checkout_any_time': role.checkout_any_time,
            'checkout_time': role.checkout_time,
            'zones': UserZonesSerializer(zones, many=True).data,
        }

    def get_score(self, instance: User):
        from auth_user.services import calculate_score_for_current_month
        if not hasattr(instance, 'role'):
            return None
        return calculate_score_for_current_month(instance.role)

    def to_internal_value(self, data):
        from auth_user.services import clean_phone_number
        data = super().to_internal_value(data)
        data['phone_number'] = clean_phone_number(data['phone_number'])
        return data


class UserZonesSerializer(serializers.Serializer):
    address = serializers.CharField()
    latitude = serializers.DecimalField(max_digits=22, decimal_places=6)
    longitude = serializers.DecimalField(max_digits=22, decimal_places=6)
    radius = serializers.IntegerField()


class OwnerCompanySerializer(serializers.Serializer):
    id = serializers.IntegerField()
    name = serializers.CharField()
    invite_code = serializers.CharField()
    years_of_work = serializers.IntegerField()
    is_active = serializers.SerializerMethodField()  # Deprecated since 14 Feb. 2024
    max_employees_qty = serializers.IntegerField()

    def get_is_active(self, instance):
        return True


class OwnerProfileSerializer(serializers.Serializer):
    id = serializers.IntegerField(required=False, read_only=True)
    first_name = serializers.CharField(max_length=50)
    last_name = serializers.CharField(max_length=50)
    middle_name = serializers.CharField(max_length=50, allow_blank=True)
    phone_number = serializers.CharField()
    email = serializers.EmailField(required=False, read_only=True)
    avatar = serializers.ImageField(required=False, allow_null=True)
    language = serializers.CharField(required=False)
    selected_company = OwnerCompanySerializer()
    pending_users = serializers.SerializerMethodField()

    def validate_phone_number(self, phone_number_raw: str):
        from auth_user.services import validate_and_clean_phone_number
        current_user = self.context['request'].user
        return validate_and_clean_phone_number(current_user, phone_number_raw)

    def get_pending_users(self, instance: User):
        return PendingUser.objects.filter(department__company=instance.selected_company).count()

    def to_internal_value(self, data):
        from auth_user.services import clean_phone_number
        data = super().to_internal_value(data)
        data['phone_number'] = clean_phone_number(data['phone_number'])
        return data


class OwnerProfileUpdateSerializer(serializers.Serializer):
    first_name = serializers.CharField(max_length=50)
    last_name = serializers.CharField(max_length=50)
    middle_name = serializers.CharField(max_length=50, allow_blank=True)
    phone_number = serializers.CharField()
    language = serializers.CharField(required=False)
    selected_company = serializers.PrimaryKeyRelatedField(queryset=Company.objects.only('id'), required=False)


class UserSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    first_name = serializers.CharField(max_length=50)
    last_name = serializers.CharField(max_length=50)
    middle_name = serializers.CharField(max_length=50, allow_blank=True)
    email = serializers.EmailField()
    phone_number = serializers.CharField()
    avatar = serializers.ImageField()
    created_at = serializers.DateTimeField()


class UserShortSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    middle_name = serializers.CharField()
    avatar = serializers.SerializerMethodField()
    position = serializers.SerializerMethodField()

    def get_avatar(self, instance: User):
        if instance.avatar:
            return settings.CURRENT_SITE + instance.avatar.url
        return None

    def get_position(self, instance: User):
        try:
            role = instance.role
        except ObjectDoesNotExist:
            role = None
        if role:
            return role.title

        if Company.objects.filter(owner=instance).exists():
            return _('Руководитель компании')

        return _('Нет должности')


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField()
    new_password = serializers.CharField()
    user_id = serializers.PrimaryKeyRelatedField(queryset=User.objects.only('id'), required=False)

    def to_internal_value(self, data):
        data = super().to_internal_value(data)
        if 'user_id' in data:
            data['user'] = data.pop('user_id')
        return data

    def validate(self, attrs):
        attrs = super().validate(attrs)
        user = attrs.get('user', self.context['user'])
        password_validation.validate_password(attrs.get('new_password'), user)
        return attrs