from django.contrib import admin
from checklist.models import *


@admin.register(Checklist)
class ChecklistAdmin(admin.ModelAdmin):
    list_display = ('company', 'name', 'department')
    search_fields = ('company__name', 'name',)


@admin.register(ChecklistSchedule)
class ChecklistScheduleAdmin(admin.ModelAdmin):
    list_display = ('checklist', 'week_day', 'time_from', 'time_to',)
    search_fields = ('checklist__name',)


@admin.register(ChecklistAssign)
class ChecklistAssignAdmin(admin.ModelAdmin):
    list_display = ('checklist', 'user', 'type', 'created_at',)
    raw_id_fields = ('user', 'checklist',)
    search_fields = ('user__email', 'user__last_name', 'user__first_name', 'user__middle_name', 'checklist__name',)


@admin.register(ChecklistComplete)
class ChecklistCompleteAdmin(admin.ModelAdmin):
    list_display = ('user', 'checklist', 'date', 'points', 'status',)
    search_fields = ('user__email',)
    list_filter = ('status',)


@admin.register(TaskGroup)
class TaskGroupAdmin(admin.ModelAdmin):
    list_display = ('name', 'checklist',)
    raw_id_fields = ('checklist',)
    search_fields = ('name', 'checklist__name',)


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ('name', 'group',)
    raw_id_fields = ('group',)
    search_fields = ('name', 'group__name',)


@admin.register(TaskFile)
class TaskFileAdmin(admin.ModelAdmin):
    list_display = ('task', 'file',)
    raw_id_fields = ('task', 'file',)
    search_fields = ('task__name', 'file',)


@admin.register(File)
class FileAdmin(admin.ModelAdmin):
    list_display = ('file_name', 'file_size', 'uploaded_by',)
    raw_id_fields = ('uploaded_by',)
    search_fields = ('file_name',)
