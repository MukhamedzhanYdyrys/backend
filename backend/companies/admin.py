from django.contrib import admin
from companies.models import Company, Department, Role, Zone


@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'owner', 'is_deleted', 'max_employees_qty',)
    search_fields = ('name', 'owner__first_name', 'owner__last_name',)
    raw_id_fields = ('owner',)


@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ('name',  'id', 'company', 'company_id')
    search_fields = ('name', 'company__name')
    raw_id_fields = ('company', 'head_of_department')


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('id', 'company', 'company_id', 'department', 'department_id', 'get_user_email', 'role', 'title', 'user_last_name', 'user_first_name')
    search_fields = ('id', 'company__name', 'department__name', 'user__email', 'user__last_name', 'user__first_name', 'user__middle_name')
    list_filter = ('company', 'role')
    raw_id_fields = ('company', 'department', 'user')

    @admin.display(ordering='user__email', description='User email')
    def get_user_email(self, obj):
        return obj.user.email

    @admin.display(ordering='user__last_name', description='User last name')
    def user_last_name(self, obj):
        return obj.user.last_name

    @admin.display(ordering='user__first_name', description='User first name')
    def user_first_name(self, obj):
        return obj.user.first_name


@admin.register(Zone)
class ZoneAdmin(admin.ModelAdmin):
    list_display = ('id', 'company', 'address')
