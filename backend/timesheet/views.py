from datetime import datetime
from datetime import timedelta, date
from drf_yasg.utils import swagger_auto_schema

from django.db import IntegrityError
from django.utils.translation import gettext_lazy as _
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.viewsets import GenericViewSet
from rest_framework.mixins import CreateModelMixin, ListModelMixin
from rest_framework.response import Response

from companies.models import Role
from common.manual_parameters import QUERY_DATE
from common.dates import timezone_from_str
from common.exceptions import CustomException
from checklist.services import checklist_assigns_for_user, control_checklists
from checklist.serializers import ChecklistAssignSerializer, ChecklistControlSerializer
from timesheet.models import TimeSheet, TimeSheetChoices, EmployeeSchedule
from timesheet.serializers import TimeSheetModelSerializer, CheckInSerializer, CheckOutSerializer, \
    EmployeeScheduleSerializer
from timesheet.services import get_missed_timesheet, CachedSchedule, get_schedule_for_role, \
    perform_check_in, perform_check_out


class TimeSheetOverviewApiView(APIView):
    @swagger_auto_schema(manual_parameters=[QUERY_DATE])
    def get(self, request):
        user = request.user
        role = Role.objects.filter(user=user).first()

        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        tz = timezone_from_str(role.department.timezone)
        now = datetime.now(tz)
        today = now.date()

        day_str = request.GET.get('date')
        if day_str:
            timesheet = None
            day = datetime.strptime(day_str, '%Y-%m-%d').date()
        else:
            timesheet = TimeSheet.objects.filter(
                role=role,
                check_in__isnull=False,
                check_out__isnull=True,
                day__lte=today,
            ).order_by('-day').exclude(status=TimeSheetChoices.BEG_OFF).first()
            day = timesheet.day if timesheet else today

        assigns = checklist_assigns_for_user(user, day)
        ctx = {'user': user, 'date': day}
        checklists_data = ChecklistAssignSerializer(assigns, many=True, context=ctx).data

        if not timesheet:
            timesheet = TimeSheet.objects.filter(role=role, day=day).first()

        if timesheet:
            timesheet_data = TimeSheetModelSerializer(timesheet).data
        else:
            timesheet_data = get_missed_timesheet(CachedSchedule(role), day)

        if timesheet and timesheet.status == TimeSheetChoices.ON_VACATION:
            vacation_timesheets = TimeSheet.objects.filter(
                role=role, status__in=[TimeSheetChoices.ON_VACATION, TimeSheetChoices.DAY_OFF],
            )

            vacation_to = today + timedelta(days=1)
            while vacation_timesheets.filter(day=vacation_to).exists() or not get_schedule_for_role(role, vacation_to):
                vacation_to += timedelta(days=1)

            timesheet_data['vacation_to'] = vacation_to

        schedule = get_schedule_for_role(role, day)
        schedule_data = None
        if schedule:
            schedule_data = {
                'time_from': schedule.time_from,
                'time_to': schedule.time_to,
                'is_night_shift': schedule.is_night_shift,
                'is_remote': schedule.is_remote,
            }

        return Response({
            'checklists': checklists_data,
            'timesheet': timesheet_data,
            'schedule': schedule_data,
            'in_zone': role.in_zone,
            'checkout_any_time': role.checkout_any_time,
            'checkout_time': role.checkout_time,
        })


class CheckInViewSet(CreateModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)

    @swagger_auto_schema(request_body=CheckInSerializer)
    def create(self, request, *args, **kwargs):
        try:
            timesheet = TimeSheet.objects.get(id=kwargs['id'])
            if timesheet.role.user != request.user:
                return Response({'message': _('Вы не можете сделать check in за другого работника')}, status.HTTP_403_FORBIDDEN)

            serializer = CheckInSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            perform_check_in(timesheet, serializer.validated_data)

            return Response({'message': 'created'})

        except CustomException as e:
            return e.as_response()

        except IntegrityError as e:
            return Response({'message': _("Вы уже осуществили check in сегодня")}, status.HTTP_423_LOCKED)


class CheckOutViewSet(CreateModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)

    @swagger_auto_schema(request_body=CheckOutSerializer)
    def create(self, request, *args, **kwargs):
        try:
            timesheet = TimeSheet.objects.get(id=kwargs['id'])
            if timesheet.role.user != request.user:
                return Response({'message': _('Вы не можете сделать check out за другого работника')}, status.HTTP_403_FORBIDDEN)

            serializer = CheckOutSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            validated_data = serializer.validated_data

            perform_check_out(timesheet, validated_data)

            return Response({'message': 'created'})

        except CustomException as e:
            return e.as_response()


class ChecklistControlView(CreateModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)

    @swagger_auto_schema(request_body=ChecklistControlSerializer)
    def create(self, request, *args, **kwargs):
        timesheet = get_object_or_404(TimeSheet, id=kwargs['id'])
        if timesheet.role != request.user.role:
            # todo: extract as CustomException
            return Response(
                {'message': _('Вы не можете управлять чек-листом за другого работника')},
                status.HTTP_403_FORBIDDEN
            )

        user = request.user
        day: date = timesheet.day

        serializer = ChecklistControlSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            checklist_status = control_checklists(user, day, serializer.data)
        except CustomException as e:
            return e.as_response()

        return Response(status=checklist_status)


class EmployeeSchedulesViewSet(ListModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)
    serializer_class = EmployeeScheduleSerializer
    queryset = EmployeeSchedule.objects.all()

    def filter_queryset(self, queryset):
        queryset = queryset.filter(role__user=self.request.user)
        return super().filter_queryset(queryset)
