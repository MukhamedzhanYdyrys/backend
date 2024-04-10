from django.contrib import admin
from auth_user.models import User, PendingUser
from django.contrib.auth.admin import UserAdmin


@admin.register(User)
class UserAdmin(UserAdmin):
    list_display = ('id', 'email', 'full_name', 'is_active', 'type')
    list_display_links = ('id', 'email', 'full_name')
    list_filter = ('is_active', 'is_superuser', 'type')
    raw_id_fields = ('selected_company',)
    search_fields = ('id', 'email', 'last_name', 'first_name', 'middle_name', 'phone_number')

    ordering = ("email",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (
            "Personal info",
            {
                "fields": (
                    "first_name",
                    "last_name",
                    "middle_name",
                    "phone_number",
                    "avatar",
                    "selected_company",
                    "language",
                    "type",
                )
            }
        ),
        (
            "Permissions",
            {
                "fields": (
                    "assistant_type",
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "is_admin",
                ),
            },
        ),
        (
            "Important dates",
            {
                "fields": (
                    "last_login",
                    "created_at",
                )
            }
        ),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("username", "password1", "password2"),
            },
        ),
    )
    readonly_fields = ('created_at', 'last_login', )


@admin.register(PendingUser)
class PendingUserAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'full_name', 'department')
    list_display_links = ('id', 'email', 'full_name')
    raw_id_fields = ('department',)
    search_fields = ('id', 'email', 'full_name', 'phone_number')
    readonly_fields = ('password_hash',)
