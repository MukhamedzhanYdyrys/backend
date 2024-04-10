from django.urls import path
from rest_framework.routers import DefaultRouter

from companies import views

router = DefaultRouter()
router.register('departments', views.DepartmentViewSet, basename='department')
router.register('employees/pending', views.PendingUsersViewSet, basename='employees-pending')
router.register('employees', views.EmployeesViewSet, basename='employees')
router.register('company', views.CompanyCreateViewSet, basename='company')
router.register('zone', views.ZoneViewSet, basename='zone-viewset')


urlpatterns = [
    path('company/<int:id>/users/', views.UsersViewSet.as_view({'get': 'list'}), name='company-users'),
] + router.urls