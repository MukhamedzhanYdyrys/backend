from datetime import datetime
from drf_yasg.utils import swagger_auto_schema

from rest_framework import status
from rest_framework import serializers
from rest_framework.response import Response
from rest_framework.mixins import ListModelMixin, CreateModelMixin
from rest_framework.viewsets import GenericViewSet, ModelViewSet
from rest_framework.permissions import IsAuthenticated

from checklist.serializers import ChecklistControlSerializer, ChecklistAssignSerializer, ChecklistManageSerializer
from checklist.services import checklist_assigns_for_user, control_checklists, update_checklist
from checklist.models import Checklist
from common.manual_parameters import QUERY_DATE
from common.exceptions import InvalidDateFormatException, CustomException
from common.dates import server_now


class ChecklistControlOwnerViewSet(ListModelMixin, CreateModelMixin, GenericViewSet):
    serializer_class = None

    def get_serializer_class(self):
        if self.action == 'create':
            return ChecklistControlSerializer
        return None

    @swagger_auto_schema(manual_parameters=[QUERY_DATE])
    def list(self, request, *args, **kwargs):
        query_date_str = request.GET.get('date')
        if query_date_str:
            try:
                day = datetime.strptime(query_date_str, '%Y-%m-%d').date()
            except ValueError:
                return InvalidDateFormatException().as_response()
        else:
            # TODO: Use the user time instead
            day = server_now().date()

        assigns = checklist_assigns_for_user(request.user, day)
        context = {'user': request.user, 'date': day}
        checklists_data = ChecklistAssignSerializer(assigns, many=True, context=context).data

        return Response({'checklists': checklists_data})

    def create(self, request, *args, **kwargs):
        user = request.user
        day = server_now().date()

        serializer = ChecklistControlSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            checklist_status = control_checklists(user, day, serializer.data)
        except CustomException as e:
            return e.as_response()

        return Response(status=checklist_status)


class ChecklistManageApiView(ModelViewSet):

    queryset = Checklist.objects.all().order_by('-id')
    serializer_class = ChecklistManageSerializer
    permission_classes = (IsAuthenticated,)

    def filter_queryset(self, queryset):
        return super().filter_queryset(queryset).filter(company=self.request.user.selected_company)

    def create(self, request, *args, **kwargs):
        try:
            update_checklist(None, request)
            return Response({'message': 'created'}, status=status.HTTP_201_CREATED)
        except serializers.ValidationError as e:
            return Response({'message': str(e.detail[0])}, status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        checklist: Checklist = self.get_object()
        try:
            update_checklist(checklist, request)
            return Response({'message': 'updated'}, status=status.HTTP_200_OK)
        except serializers.ValidationError as e:
            return Response({'message': str(e.detail[0])}, status.HTTP_400_BAD_REQUEST)
