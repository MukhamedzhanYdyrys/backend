from django.urls import path

from timesheet import views


urlpatterns = [
    path('', views.TimeSheetOverviewApiView.as_view(), name='active-timesheet'),
    path('<int:id>/check-in/', views.CheckInViewSet.as_view({'post': 'create'}), name='check-in'),
    path('<int:id>/check-out/', views.CheckOutViewSet.as_view({'post': 'create'}), name='check-out'),
    path('<int:id>/checklist/', views.ChecklistControlView.as_view({'post': 'create'}), name='checklist'),
    path('schedules/', views.EmployeeSchedulesViewSet.as_view({'get': 'list'}), name='schedules'),
]