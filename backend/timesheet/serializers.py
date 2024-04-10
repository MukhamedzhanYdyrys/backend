from rest_framework import serializers

from timesheet.models import TimeSheet, TimeSheetChoices, EmployeeSchedule


class TimeSheetModelSerializer(serializers.ModelSerializer):
    status_decoded = serializers.SerializerMethodField(read_only=True)
    working_hours = serializers.SerializerMethodField(read_only=True)
    timezone_schedule = serializers.SerializerMethodField(read_only=True)  # deprecated since 7 Feb 2024
    timezone = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = TimeSheet
        exclude = ('created_at', 'updated_at', 'debug_comment',)

    # deprecated since 7 Feb 2024
    def get_timezone_schedule(self, instance: TimeSheet):
        return instance.timezone

    def get_timezone(self, instance: TimeSheet):
        return instance.timezone

    def get_status_decoded(self, instance):
        return TimeSheetChoices.get_status(instance.status)

    def get_working_hours(self, instance):
        if instance.check_in and instance.check_out and instance.status in [1, 2]:
            return (instance.check_out - instance.check_in).total_seconds() / 3600
        return ''


class CheckInSerializer(serializers.Serializer):
    device_id = serializers.CharField()
    latitude = serializers.DecimalField(max_digits=22, decimal_places=6, required=False)
    longitude = serializers.DecimalField(max_digits=22, decimal_places=6, required=False)
    file = serializers.FileField(allow_null=True, required=False)
    comment = serializers.CharField(allow_null=True, required=False)


class CheckOutSerializer(serializers.Serializer):
    device_id = serializers.CharField()
    latitude = serializers.DecimalField(max_digits=22, decimal_places=6)
    longitude = serializers.DecimalField(max_digits=22, decimal_places=6)
    custom_date = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S%z', required=False, allow_null=True)


class EmployeeScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmployeeSchedule
        exclude = ['id', 'created_at', 'updated_at', 'role']
