import random

from django.utils.crypto import get_random_string
from django.utils.translation import gettext_lazy as _
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.viewsets import GenericViewSet
from rest_framework.mixins import UpdateModelMixin
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.exceptions import ValidationError, AuthenticationFailed
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_yasg.utils import swagger_auto_schema

from auth_user.serializers import PendingUserSerializer, SendSmsSerializer, VerifySmsSerializer, \
    SetPasswordViaSmsSerializer, TokenCredentialsSerializer, UserProfileSerializer, OwnerProfileSerializer, \
    OwnerProfileUpdateSerializer, ChangePasswordSerializer
from auth_user.services import create_pending_user, clean_phone_number, send_sms, is_valid_password, \
    get_additional_user_info, update_user_profile, get_user_role, change_password
from auth_user.models import User, OtpToken, ResetPasswordToken
from common.exceptions import CustomException, PhoneNumberExistsException, UserNotFoundException, \
    MustUsePasswordException, InviteCodeNotFoundException, InviteCodeRequiredException, InvalidOtpTokenException, \
    InactiveUserException, InvalidCredentialsException
from common.manual_parameters import QUERY_INVITE_CODE
from companies.models import Company, Department


class RegisterApi(GenericViewSet):
    parser_classes = (MultiPartParser,)
    serializer_class = PendingUserSerializer

    def post(self, request):
        serializer = PendingUserSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            create_pending_user(serializer.validated_data)
            return Response({'message': 'created'}, status=status.HTTP_201_CREATED)
        except CustomException as e:
            return e.as_response()


class SendSmsApi(APIView):
    @swagger_auto_schema(request_body=SendSmsSerializer)
    def post(self, request):
        action = request.data.get('action')
        is_forgot_password = action == 'change_password'
        is_changing_number = action == 'change_number'
        is_register_employee = action == 'register_employee'
        is_register_owner = action == 'register_owner'

        phone_number = clean_phone_number(request.data.get('phone_number'))
        user = User.objects.filter(phone_number=phone_number).first()
        company = None

        num_actions = (is_forgot_password + is_changing_number + is_register_employee + is_register_owner)
        if num_actions > 1:
            return Response({'message': 'Invalid actions'}, status=status.HTTP_400_BAD_REQUEST)

        if is_changing_number:
            if not request.user.is_authenticated:
                return Response(
                    {'message': _('Невозможно сменить номер без авторизаций')},
                    status=status.HTTP_401_UNAUTHORIZED,
                )

            if user:
                return PhoneNumberExistsException().as_response()
            user = request.user
            action = 'change_number'

        elif is_forgot_password:
            if not user:
                return UserNotFoundException().as_response()
            action = 'change_password'

        elif is_register_owner:
            if user:
                return MustUsePasswordException().as_response()
            action = 'register_owner'

        else:
            if user:
                # TODO: only if password is not set
                return MustUsePasswordException().as_response()
            action = 'register_employee'

            invite_code = request.data.get('invite_code')
            if not invite_code:
                return InviteCodeRequiredException().as_response()

            company = Company.objects.filter(invite_code=invite_code).first()
            if not company:
                return InviteCodeNotFoundException().as_response()

        code = f'{random.randrange(10)}{random.randrange(10)}{random.randrange(10)}{random.randrange(10)}'
        try:
            print(f'Code: {code}')
            # send_sms(phone_number, f'Ваш код подтверждения: {code}')
        except CustomException as e:
            return e.as_response()

        token = OtpToken.objects.create(
            user=user,
            code=code,
            token=get_random_string(length=32),
            phone_number=phone_number,
            company=company,
            action=action,
        )
        return Response({
            'message': _('СМС успешно отправлено!'),
            'code': 'ok',
            'otp_token': token.token,
        })


class VerifySmsApi(APIView):
    @swagger_auto_schema(request_body=VerifySmsSerializer)
    def post(self, request):
        serializer = VerifySmsSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        code = serializer.validated_data['code']

        # Clean expired OTP tokens
        OtpToken.objects.filter(created_at__lt=OtpToken.exp_date()).delete()

        otp_token = OtpToken.objects.filter(token=serializer.validated_data['otp_token']).first()
        if not otp_token:
            return InvalidOtpTokenException().as_response()

        stage_code = '0000'
        if code not in [otp_token.code, stage_code]:
            # TODO: extract as CustomException
            return Response({'message': _('Неправильный код!'), 'status': 'invalid-code'}, status=status.HTTP_400_BAD_REQUEST)

        otp_token.verified = True
        otp_token.save(update_fields=['verified'])

        if otp_token.action == 'change_number':
            otp_token.user.phone_number = otp_token.phone_number
            otp_token.user.save(update_fields=['phone_number'])

            return Response({'action': otp_token.action, 'status': 'ok'})

        if otp_token.action == 'change_password':
            # Clean expired tokens
            ResetPasswordToken.objects.filter(created_at__lt=ResetPasswordToken.exp_date()).delete()

            token = get_random_string(length=32)
            ResetPasswordToken.objects.create(user=otp_token.user, token=token)

            return Response({'action': otp_token.action, 'reset_token': token, 'status': 'ok'})

        return Response({'action': otp_token.action, 'otp_token': otp_token.token, 'status': 'ok'})


class SetPasswordViaSmsApi(APIView):
    @swagger_auto_schema(request_body=SetPasswordViaSmsSerializer)
    def post(self, request):
        token = request.data['reset_token']
        reset_token = ResetPasswordToken.objects.filter(token=token, created_at__gt=ResetPasswordToken.exp_date()).first()
         # todo: extract as CustomException. InvalidOtpTokenException exist
        if not reset_token:
            return Response({'message': _('Ваша сессия устарела, начните заново')}, status=status.HTTP_400_BAD_REQUEST)

        new_password = request.data['new_password']
        try:
            is_valid_password(new_password)
        except ValidationError as e:
            if type(e.detail) is list:
                return Response({'message': _(e.args[0])}, status=status.HTTP_400_BAD_REQUEST)
            raise e

        reset_token.user.set_password(new_password)
        reset_token.user.save(update_fields=['password'])
        reset_token.delete()

        return Response({'message': _('Пароль успешно изменен!')}, status=status.HTTP_200_OK)


class CustomTokenObtainPairView(TokenObtainPairView):
    """
    Takes a set of user credentials and returns an access and refresh JSON web
    token pair to prove the authentication of those credentials.
    """
    permission_classes = (AllowAny,)
    serializer_class = TokenCredentialsSerializer

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        phone_number = request.data.get('phone_number')

        user = None
        if email:
            user = User.objects.filter(email=email).first()
        if not user and phone_number:
            phone_number = clean_phone_number(phone_number)
            user = User.objects.filter(phone_number=phone_number).first()

        if user and user.check_password(request.data.get('password')):
            try:
                user_data = get_additional_user_info(user)
            except InactiveUserException as e:
                return e.as_response()

            if user_data and user_data['role'] != 'no_role':
                request.data['email'] = user_data['email']
                try:
                    resp = super().post(request, *args, **kwargs)
                    resp.data['user'] = user_data
                    return resp
                except AuthenticationFailed:
                    pass

        return InvalidCredentialsException().as_response()


class CustomTokenRefreshView(TokenRefreshView):
    """
    Takes a refresh type JSON web token and returns an access type JSON web
    token if the refresh token is valid.
    """
    permission_classes = (AllowAny,)


class UserProfileView(UpdateModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)
    queryset = User.objects.all()
    serializer_class = UserProfileSerializer
    lookup_field = "pk"

    def get(self, request, *args, **kwargs):
        serializer = self.serializer_class(self.request.user, context={'request': request})
        serializer_data = serializer.data
        return Response(serializer_data, status=status.HTTP_200_OK)

    def update(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        response, status_code = update_user_profile(request.user, serializer)
        return Response(response, status=status_code)


class OwnerProfileView(UpdateModelMixin, GenericViewSet):
    permission_classes = (IsAuthenticated,)
    queryset = User.objects.all()
    serializer_class = OwnerProfileSerializer
    lookup_field = "pk"

    def get_serializer_class(self):
        if self.action == 'update':
            return OwnerProfileUpdateSerializer
        return OwnerProfileSerializer

    def get(self, request, *args, **kwargs):
        user = request.user
        serializer = self.serializer_class(user, context={'request': request})
        serializer_data = serializer.data
        serializer_data['role'] = {'role': get_user_role(user)}
        return Response(serializer_data, status=status.HTTP_200_OK)

    def update(self, request, *args, **kwargs):
        serializer = OwnerProfileUpdateSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        response, status_code = update_user_profile(request.user, serializer)
        return Response(response, status=status_code)


class GetDepartmentsApi(APIView):
    @swagger_auto_schema(manual_parameters=[QUERY_INVITE_CODE])
    def get(self, request):
        invite_code = request.GET.get('invite_code')
        company = Company.objects.filter(invite_code=invite_code).first() if invite_code else None
        if not company:
            return InviteCodeNotFoundException().as_response()

        departments = Department.objects.filter(company=company)
        result = map(lambda x: {'id': x.id, 'name': x.name}, departments)
        return Response(result)


class ChangePasswordView(GenericViewSet):
    queryset = User.objects.order_by()
    serializer_class = ChangePasswordSerializer
    permission_classes = (IsAuthenticated, )

    def change_password(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data.pop('user', request.user)
        change_password(user, serializer.validated_data)
        return Response({'message': 'updated'}, status=status.HTTP_200_OK)
