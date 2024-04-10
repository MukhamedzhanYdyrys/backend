from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from companies.models import Company, Department, User
from config import settings
from timesheet.models import WeekDayChoices
from common.models import BaseModel


class Checklist(BaseModel):
    name = models.TextField()
    start_date = models.DateField(null=True, blank=True)
    company = models.ForeignKey(to=Company, on_delete=models.CASCADE, related_name='checklists')
    department = models.ForeignKey(to=Department, null=True, on_delete=models.SET_NULL, related_name='checklists')
    timezone = models.CharField(max_length=64, default=settings.TIME_ZONE)

    executor_reward = models.PositiveIntegerField(default=0)
    executor_penalty_late = models.PositiveIntegerField(default=0)
    executor_penalty_not_completed = models.PositiveIntegerField(default=0)

    inspector_reward = models.PositiveIntegerField(default=0)
    inspector_penalty_late = models.PositiveIntegerField(default=0)
    inspector_penalty_not_completed = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.name


class ChecklistSchedule(BaseModel):
    checklist = models.ForeignKey(to=Checklist, on_delete=models.CASCADE, related_name='schedules')
    week_day = models.IntegerField(choices=WeekDayChoices.choices, validators=[MinValueValidator(0), MaxValueValidator(6)])
    time_from = models.TimeField(null=True, blank=True)
    time_to = models.TimeField(null=True, blank=True)
    notified_day = models.DateField(null=True, blank=True)

    class Meta:
        unique_together = ('checklist', 'week_day')

    def __str__(self):
        return f'{self.checklist} - {self.week_day}'


class ChecklistAssignTypes(models.IntegerChoices):
    EXECUTOR = 1, 'Executor'
    INSPECTOR = 2, 'Inspector'

    @staticmethod
    def get_enum(assign_type):
        if assign_type == ChecklistAssignTypes.EXECUTOR:
            return 'executor'
        elif assign_type == ChecklistAssignTypes.INSPECTOR:
            return 'inspector'
        return 'none'


class ChecklistAssign(BaseModel):
    type = models.IntegerField(choices=ChecklistAssignTypes.choices, default=ChecklistAssignTypes.EXECUTOR)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    checklist = models.ForeignKey(Checklist, on_delete=models.CASCADE, related_name='assigns')

    class Meta:
        unique_together = ('user', 'checklist', 'type',)


class ChecklistCompleteStatuses(models.IntegerChoices):
    COMPLETED_ON_TIME = 1, 'Completed On Time'
    COMPLETED_LATE = 2, 'Completed Late'
    NOT_COMPLETED = 3, 'Not Completed'
    INFORMATIVE = 4, 'Informative'
    BEG_OFF = 5, 'Beg Off'


class ChecklistComplete(BaseModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    checklist = models.ForeignKey(Checklist, on_delete=models.CASCADE, related_name='completes')
    date = models.DateField()
    points = models.IntegerField(default=0)
    status = models.IntegerField(choices=ChecklistCompleteStatuses.choices)


class TaskGroup(BaseModel):
    name = models.TextField()
    checklist = models.ForeignKey(Checklist, on_delete=models.CASCADE, related_name='groups')
    checkbox = models.BooleanField(default=False)

    def __str__(self):
        # if self.time_from or self.time_to:
        #     return f'{self.name} ({self.time_from.strftime("%H:%M")} - {self.time_to.strftime("%H:%M")})'
        return self.name


class Task(BaseModel):
    name = models.TextField()
    group = models.ForeignKey(TaskGroup, on_delete=models.CASCADE, related_name='tasks')

    def __str__(self):
        return self.name


class TaskCheck(BaseModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    date = models.DateField()


class File(BaseModel):
    file_name = models.TextField()
    file_size = models.PositiveBigIntegerField(help_text='File size in bytes')
    uploaded_by = models.ForeignKey(User, null=True, on_delete=models.SET_NULL, related_name='files')
    local_file = models.FileField(upload_to='files/', null=True, blank=True)
    s3_url = models.TextField(null=False, blank=True)

    @property
    def url(self):
        return (settings.CURRENT_SITE + self.local_file.url) if self.local_file else self.s3_url

    def to_dict(self):
        return {
            'id': self.id,
            'file_name': self.file_name,
            'file_size': self.file_size,
            'url': self.url,
        }

    def __str__(self):
        return self.file_name


class TaskFile(BaseModel):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='files')
    file = models.ForeignKey(File, on_delete=models.CASCADE, related_name='task_files')
