from django.urls import path, include


urlpatterns = [
    path('', include('auth_user.urls'), name='auth'),
    path('', include('companies.urls'), name='companies'),
    path('timesheet/', include('timesheet.urls'), name='timesheet'),
    path('checklist/', include('checklist.urls'), name='checklists'),
]