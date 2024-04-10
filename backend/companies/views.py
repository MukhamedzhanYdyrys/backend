import sys

from drf_yasg.utils import swagger_auto_schema

from django_filters.rest_framework import DjangoFilterBackend
from django.shortcuts import get_object_or_404
from django.db.models import Q
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.viewsets import ModelViewSet, GenericViewSet
from rest_framework.mixins import ListModelMixin, CreateModelMixin, DestroyModelMixin
from rest_framework.serializers import ValidationError
from rest_framework.response import Response

from auth_user.models import User, PendingUser
from auth_user.serializers import UserShortSerializer
from companies.serializers import EmployeesSerializer, FilterEmployeesSerializer, CreateEmployeeSerializer, \
    DepartmentSerializer, DepartmentList2Serializer, CreateCompanySerializer, ZoneListSerializer, ZoneCreateSerializer, \
    PendingUserListSerializer
from companies.services import get_employee_list, create_employee, update_employee, get_departments_qs, \
    create_department, update_department, delete_head_of_department_role, check_company_existence, \
    check_email_existence,  create_company, get_zones_qs
from companies.models import Role, Company
from common.manual_parameters import QUERY_DEPARTMENTS, QUERY_COMPANY, QUERY_DEPARTMENT
from common.exceptions import CustomException, CompanyAccessDeniedException
from common.permissions import has_permission_for_company


class EmployeesViewSet(ModelViewSet):
    permission_classes = (IsAuthenticated,)
    serializer_class = EmployeesSerializer
    filter_backends = (SearchFilter, DjangoFilterBackend, OrderingFilter)
    search_fields = ('user__first_name', 'user__last_name', 'user__middle_name',)
    filterset_fields = ('company', 'department',)
    ordering_fields = ('score',)
    http_method_names = ('get', 'post', 'put', 'delete',)
    filter_serializer = None

    def get_queryset(self):
        return get_employee_list()

    def filter_queryset(self, queryset):
        queryset = super().filter_queryset(queryset)

        if self.filter_serializer:
            data = self.filter_serializer.validated_data
            if 'departments' in data:
                queryset = queryset.filter(department__in=data['departments'])

        return queryset

    @swagger_auto_schema(manual_parameters=[QUERY_DEPARTMENTS])
    def list(self, request, *args, **kwargs):
        self.paginator.page_size = sys.maxsize  # by default pagination is disabled
        self.filter_serializer = FilterEmployeesSerializer(data=request.query_params)
        self.filter_serializer.is_valid(raise_exception=True)
        return super().list(request, *args, **kwargs)

    @swagger_auto_schema(request_body=CreateEmployeeSerializer)
    def create(self, request, *args, **kwargs):
        try:
            serializer = CreateEmployeeSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            create_employee(serializer.validated_data)
            return Response({'message': 'created'})
        except ValidationError as e:
            return Response(e.detail, status.HTTP_400_BAD_REQUEST)
        except CustomException as e:
            return e.as_response()

    @swagger_auto_schema(request_body=CreateEmployeeSerializer)
    def update(self, request, *args, **kwargs):
        try:
            serializer = CreateEmployeeSerializer(data=request.data)
            serializer.instance = self.get_object()
            serializer.is_valid(raise_exception=True)
            update_employee(request, self.get_object(), serializer.validated_data)
            return Response({'message': 'updated'}, status=status.HTTP_200_OK)
        except CustomException as e:
            return e.as_response()

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()

        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    def destroy(self, request, *args, **kwargs):
        instance: Role = self.get_object()
        instance.user.delete()
        instance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DepartmentViewSet(ModelViewSet):
    permission_classes = (IsAuthenticated,)
    filter_backends = (SearchFilter, DjangoFilterBackend)
    filterset_fields = ('company',)
    search_fields = ('name',)
    http_method_names = ['get', 'post', 'put', 'delete']

    def get_serializer_class(self):
        if self.action in ['create', 'update']:
            return DepartmentSerializer
        return DepartmentList2Serializer

    def get_queryset(self):
        return get_departments_qs()

    @swagger_auto_schema(request_body=DepartmentSerializer)
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            create_department(request.user.selected_company, serializer.validated_data)
        except CustomException as e:
            return e.as_response()
        except Exception as e:
            if type(e.args[0]) is dict and e.args[0]['status'] == 400:
                return Response({'message': e.args[0]['message']}, status=e.args[0]['status'])
            return Response({'message': str(e)}, status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({'message': 'created'})

    @swagger_auto_schema(manual_parameters=[QUERY_COMPANY])
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        update_department(self.get_object(), serializer.validated_data)
        return Response({'message': 'updated'}, status=status.HTTP_200_OK)

    def perform_destroy(self, instance):
        delete_head_of_department_role(instance)
        super().perform_destroy(instance)


class UsersViewSet(ListModelMixin, GenericViewSet):
    queryset = User.objects.all()
    serializer_class = UserShortSerializer

    def list(self, request, *args, **kwargs):
        company = get_object_or_404(Company, pk=kwargs['id'])

        if not has_permission_for_company(request.user, company):
            return CompanyAccessDeniedException().as_response()

        users = User.objects.filter(
            Q(role__company=company) |
            Q(owned_companies=company), is_active=True
        ).prefetch_related('role').order_by('last_name', 'first_name', 'middle_name')

        result = UserShortSerializer(users, many=True).data
        return Response(result)


class CompanyCreateViewSet(CreateModelMixin, GenericViewSet):
    permission_classes = (AllowAny, )
    serializer_class = CreateCompanySerializer
    queryset = Company.objects.all()

    @swagger_auto_schema(request_body=CreateCompanySerializer)
    def create(self, request, *args, **kwargs):
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            check_email_existence(serializer.validated_data.get('email'))
            check_company_existence(serializer.validated_data.get('company_name'))

            create_company(serializer.data)

            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

        except CustomException as e:
            return Response({'message': str(e)}, status.HTTP_423_LOCKED)


class ZoneViewSet(ModelViewSet):
    permission_classes = (IsAuthenticated,)
    filter_backends = (SearchFilter, DjangoFilterBackend)
    search_fields = ('address',)
    filterset_fields = ('company',)

    def get_queryset(self):
        return get_zones_qs()

    def get_serializer_class(self):
        if self.action in ['list', 'retrieve']:
            return ZoneListSerializer
        return ZoneCreateSerializer


class PendingUsersViewSet(GenericViewSet, ListModelMixin, DestroyModelMixin):
    permission_classes = (IsAuthenticated,)
    queryset = PendingUser.objects.all()
    serializer_class = PendingUserListSerializer

    def get_permissions(self):
        if self.action == 'destroy':
            return []
        return super().get_permissions()

    def filter_queryset(self, queryset):
        department_id = self.request.GET.get('department')
        if department_id:
            filters = {'department_id': department_id}
        else:
            filters = {'department__company_id': self.request.GET.get('company')}
        search = self.request.GET.get('search')
        if search:
            filters['full_name__icontains'] = search
        return queryset.filter(**filters).order_by('-created_at')

    @swagger_auto_schema(manual_parameters=[QUERY_COMPANY, QUERY_DEPARTMENT])
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        instance: PendingUser = get_object_or_404(PendingUser, pk=kwargs['pk'])
        instance.delete()
        return Response({'message': 'deleted'})