from datetime import datetime
from dateutil.relativedelta import relativedelta
import json

from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from auth_user.models import PendingUser
from auth_user.serializers import UserSerializer
from auth_user.services import get_role_month_overview, get_user_role, \
    validate_and_clean_phone_number, clean_phone_number
from auth_user.models import User
from companies.models import Role, Zone
from common.dates import server_now
from common.exceptions import CustomException
from timesheet.services import get_score_for_month, get_score_for_day

class DepartmentListSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    name = serializers.CharField()


class ScheduleSerializer(serializers.Serializer):
    week_day = serializers.IntegerField(min_value=0, max_value=6)
    time_from = serializers.TimeField(format='%H:%M')
    time_to = serializers.TimeField(format='%H:%M')
    is_night_shift = serializers.BooleanField(default=False)


class EmployeesSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    user = UserSerializer()
    role = serializers.IntegerField()
    grade = serializers.IntegerField()
    title = serializers.CharField()
    score = serializers.SerializerMethodField()
    score_previous = serializers.SerializerMethodField()
    department = DepartmentListSerializer()
    schedules = ScheduleSerializer(many=True)
    in_zone = serializers.BooleanField()
    checkout_any_time = serializers.BooleanField()
    checkout_time = serializers.IntegerField()
    today_schedule = serializers.SerializerMethodField()
    month_overview = serializers.SerializerMethodField()
    zones = serializers.SerializerMethodField()

    def get_zones(self, instance: Role):
        return Zone.objects.filter(employees=instance.id).values_list('id', flat=True)

    def get_month_overview(self, instance: Role):
        return get_role_month_overview(instance)

    def should_show_score(self, instance: Role):
        current_user: User = self.context['request'].user
        if get_user_role(current_user) in {'superuser', 'owner', 'co-owner', 'hr'}:
            return True
        current_user_role: Role = Role.objects.filter(user=current_user).first()
        return current_user_role and current_user_role.grade >= instance.grade

    def get_score(self, instance):
        if self.should_show_score(instance):
            now = datetime.now()
            return get_score_for_month(instance, now.year, now.month)
        return None

    def get_score_previous(self, instance):
        if not self.should_show_score(instance):
            return None

        today = server_now().date()
        day_month_ago = today - relativedelta(months=1)
        return get_score_for_day(instance, day_month_ago)

    def get_today_schedule(self, instance):
        try:
            week_day = datetime.today().weekday()
            today_schedule = list(filter(lambda p: p.week_day == week_day, instance.schedules))[0]
            time_from = today_schedule.time_from.strftime('%H:%M')
            time_to = today_schedule.time_to.strftime('%H:%M')
            return f'{time_from} - {time_to}'
        except IndexError:
            return ''


class FilterEmployeesSerializer(serializers.Serializer):
    departments = serializers.ListField(child=serializers.CharField(), required=False)

    def to_internal_value(self, data):
        data = super().to_internal_value(data)
        if 'departments' in data:
            data['departments'] = [int(i) for i in data['departments'][0].split(',')]
        return data


class CreateEmployeeSerializer(serializers.Serializer):
    first_name = serializers.CharField(allow_blank=True)
    last_name = serializers.CharField(allow_blank=True)
    middle_name = serializers.CharField(allow_blank=True)
    email = serializers.EmailField(allow_blank=True)
    phone_number = serializers.CharField(allow_blank=True)
    in_zone = serializers.BooleanField(allow_null=True)
    checkout_any_time = serializers.BooleanField(allow_null=True)
    checkout_time = serializers.IntegerField(allow_null=True)
    avatar = serializers.ImageField(allow_null=True, required=False)
    title = serializers.CharField()
    grade = serializers.IntegerField()
    department_id = serializers.IntegerField()
    pending_user_id = serializers.IntegerField(allow_null=True, required=False)
    schedules = ScheduleSerializer(many=True, required=False)
    zones = serializers.PrimaryKeyRelatedField(many=True, queryset=Zone.objects.only('id'))

    def validate_phone_number(self, phone_number_raw: str):
        current_user = self.instance.user if self.instance else None
        return validate_and_clean_phone_number(current_user, phone_number_raw)

    def to_internal_value(self, data):
        if hasattr(data, 'getlist'):
            data = data.dict()
        if isinstance(data.get('schedules'), str):
            data['schedules'] = json.loads(data['schedules'])
        if isinstance(data['zones'], str):
            data['zones'] = json.loads(data['zones'])
        if isinstance(data.get('avatar'), str) and data['avatar'] == 'null':
            data['avatar'] = None
        data['phone_number'] = clean_phone_number(data['phone_number'])
        data = super().to_internal_value(data)
        return data

    def validate(self, attrs):

        if ('first_name' in attrs and not attrs.get('first_name')) or \
                ('last_name' in attrs and not attrs.get('last_name')):
            raise CustomException(default_detail=_('Введите ФИО'))

        if 'title' in attrs and not attrs.get('title'):
            raise CustomException(default_detail=_('Введите позицию'))

        if 'grade' in attrs and not attrs.get('grade'):
            raise CustomException(default_detail=_('Укажите градацию'))

        if 'schedules' in attrs and not attrs.get('schedules'):
            raise CustomException(default_detail=_('Укажите часы работы'))

        if 'department_id' in attrs and not attrs.get('department_id'):
            raise CustomException(default_detail=_('Укажите отдел'))

        return attrs


class DepartmentSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    name = serializers.CharField()
    zones = serializers.PrimaryKeyRelatedField(many=True, queryset=Zone.objects.only('id'))
    schedules = ScheduleSerializer(many=True)
    head_of_department_id = serializers.IntegerField(allow_null=True, required=False)
    timezone = serializers.CharField()
    start_inaccuracy = serializers.IntegerField(required=False, default=0)


class HeadOfDepartmentSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    last_name = serializers.SerializerMethodField()
    first_name = serializers.SerializerMethodField()
    middle_name = serializers.SerializerMethodField()

    def get_last_name(self, instance):
        return instance.user.last_name

    def get_first_name(self, instance):
        return instance.user.first_name

    def get_middle_name(self, instance):
        return instance.user.middle_name


class DepartmentList2Serializer(DepartmentSerializer):
    head_of_department = HeadOfDepartmentSerializer()
    today_schedule = serializers.SerializerMethodField()
    employees_count = serializers.IntegerField()
    is_hr = serializers.BooleanField()

    def get_today_schedule(self, instance):
        week_day = datetime.today().weekday()
        today_schedule = instance.department_schedules.filter(week_day=week_day)
        if today_schedule:
            time_from = today_schedule[0].time_from.strftime('%H:%M')
            time_to = today_schedule[0].time_to.strftime('%H:%M')
            return f'{time_from} - {time_to}'
        return ''


class CreateCompanySerializer(serializers.Serializer):
    first_name = serializers.CharField()
    last_name = serializers.CharField(allow_blank=True, default='')
    middle_name = serializers.CharField(allow_blank=True, default='')
    email = serializers.EmailField()
    otp_token = serializers.CharField(required=True)
    # phone_number = serializers.CharField(allow_blank=True, default='')
    company_name = serializers.CharField()
    company_legal_name = serializers.CharField()
    max_employees_qty = serializers.IntegerField(default=0)
    years_of_work = serializers.IntegerField(default=0)
    password = serializers.CharField(required=True)


class ZoneEmployeeSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    user = UserSerializer()
    role = serializers.IntegerField()
    title = serializers.CharField()


class ZoneListSerializer(serializers.ModelSerializer):
    employees = ZoneEmployeeSerializer(many=True)

    class Meta:
        model = Zone
        exclude = ("created_at", 'updated_at')


class ZoneCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Zone
        exclude = ("created_at", 'updated_at')


class PendingUserListSerializer(serializers.ModelSerializer):
    avatar = serializers.FileField(required=False)
    department = DepartmentListSerializer(required=False)

    class Meta:
        model = PendingUser
        exclude = ['password_hash', 'created_at', 'updated_at']