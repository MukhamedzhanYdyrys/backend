from rest_framework.routers import DefaultRouter
from django.urls import path
from checklist import views


router = DefaultRouter()
router.register('manage', views.ChecklistManageApiView, basename='checklist-manage')
router.register('', views.ChecklistControlOwnerViewSet, basename='checklist-owner')

urlpatterns = [] + router.urls
