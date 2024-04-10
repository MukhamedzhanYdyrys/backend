from datetime import date
from rest_framework import serializers

from checklist.models import ChecklistAssign, Checklist, TaskCheck, Task, ChecklistComplete, TaskGroup, TaskFile
from checklist.models import ChecklistAssignTypes, ChecklistSchedule


class TaskSerializer(serializers.ModelSerializer):
    files = serializers.SerializerMethodField(read_only=True)
    checked = serializers.SerializerMethodField(read_only=True)

    def get_files(self, instance):
        result = []
        for file in TaskFile.objects.filter(task=instance).prefetch_related('file'):
            result.append(file.file.to_dict())
        return result

    def get_checked(self, instance):
        return TaskCheck.objects.filter(user=self.context['user'], date=self.context['date'], task=instance).exists()

    class Meta:
        model = Task
        exclude = ['created_at', 'updated_at', 'group']


class TaskGroupSerializer(serializers.ModelSerializer):
    tasks = serializers.SerializerMethodField(read_only=True)

    def get_tasks(self, instance):
        tasks = Task.objects.filter(group=instance)
        return TaskSerializer(tasks, many=True, context=self.context).data

    class Meta:
        model = TaskGroup
        exclude = ['created_at', 'updated_at', 'checklist']


class ChecklistCompleteSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChecklistComplete
        exclude = ['user', 'checklist', 'updated_at']


class ChecklistScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChecklistSchedule
        exclude = ['id', 'checklist', 'updated_at', 'created_at']


class ChecklistSerializer(serializers.ModelSerializer):
    groups = serializers.SerializerMethodField(read_only=True)
    completion = serializers.SerializerMethodField(read_only=True)
    schedule = serializers.SerializerMethodField(read_only=True)

    def get_schedule(self, instance):
        day: date = self.context['date']
        schedule = ChecklistSchedule.objects.filter(checklist=instance, week_day=day.weekday()).first()
        schedule_data = ChecklistScheduleSerializer(schedule).data
        if schedule_data['week_day'] is None:
            complete = ChecklistComplete.objects.filter(
                user=self.context['user'],
                date=self.context['date'],
                checklist=instance
            ).first()
            schedule_data['week_day'] = complete.created_at.weekday() if complete else day.weekday()
        return schedule_data

    def get_completion(self, instance):
        complete = ChecklistComplete.objects.filter(user=self.context['user'], date=self.context['date'], checklist=instance).first()
        if complete:
            return ChecklistCompleteSerializer(complete).data
        return None

    def get_groups(self, instance):
        groups = TaskGroup.objects.filter(checklist=instance)
        return TaskGroupSerializer(groups, many=True, context=self.context).data

    class Meta:
        model = Checklist
        exclude = ['company', 'created_at', 'updated_at']


class ChecklistAssignSerializer(serializers.Serializer):
    checklist = serializers.SerializerMethodField(read_only=True)
    assign_type = serializers.SerializerMethodField(read_only=True)

    def get_assign_type(self, instance):
        return ChecklistAssignTypes.get_enum(instance.type)

    def get_checklist(self, instance):
        return ChecklistSerializer(instance.checklist, context=self.context).data


class TaskManageSerializer(serializers.ModelSerializer):
    files = serializers.SerializerMethodField()

    def get_files(self, instance):
        result = []
        task_files = TaskFile.objects.filter(task=instance).prefetch_related('file')
        for task_file in task_files:
            file = task_file.file
            result.append(file.to_dict())
        return result

    class Meta:
        model = Task
        exclude = []


class TaskGroupManageSerializer(serializers.ModelSerializer):
    tasks = TaskManageSerializer(many=True)

    class Meta:
        model = TaskGroup
        exclude = []


class ChecklistManageSerializer(serializers.ModelSerializer):
    department_name = serializers.SerializerMethodField(read_only=True)
    groups = TaskGroupManageSerializer(many=True, read_only=True)
    schedules = ChecklistScheduleSerializer(many=True, read_only=True)
    executors = serializers.SerializerMethodField()
    inspectors = serializers.SerializerMethodField()

    def get_executors(self, instance: Checklist):
        return ChecklistAssign.objects.filter(type=ChecklistAssignTypes.EXECUTOR, checklist=instance).values_list('user_id', flat=True)

    def get_inspectors(self, instance: Checklist):
        return ChecklistAssign.objects.filter(type=ChecklistAssignTypes.INSPECTOR, checklist=instance).values_list('user_id', flat=True)

    def get_department_name(self, instance: Checklist):
        return instance.department.name if instance.department else None

    class Meta:
        model = Checklist
        exclude = []


class ChecklistControlSerializer(serializers.Serializer):
    checklist_id = serializers.IntegerField()
    task_id = serializers.IntegerField(allow_null=True, required=False)
    action = serializers.ChoiceField(choices=['check', 'uncheck', 'complete'])