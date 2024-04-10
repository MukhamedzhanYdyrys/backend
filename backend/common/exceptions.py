from rest_framework import status
from rest_framework.exceptions import APIException
from rest_framework.response import Response
from django.utils.translation import gettext_lazy as _


class CustomException(APIException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Ошибка')
    default_code = 'unknown'

    def __init__(self, *args, **kwargs):
        super().__init__()
        self.status_code = kwargs.get('status_code') or self.status_code
        self.default_detail = kwargs.get('default_detail') or self.default_detail
        self.default_code = kwargs.get('default_code') or self.default_code

    def as_response(self) -> Response:
        return Response(
            {'message': self.default_detail, 'code': self.default_code},
            self.status_code,
        )


class CustomResponseException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    data = None

    def __init__(self, data):
        self.data = data

    def as_response(self) -> Response:
        return Response(self.data, self.status_code)


class DepartmentNotFoundException(CustomException):
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = _('Не удалось найти отдел')
    default_code = 'department-not-found'


class InvalidOtpTokenException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Ваша сессия устарела, начните заново')
    default_code = 'invalid-otp-token'


class PhoneNumberExistsException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Этот номер телефона уже существует')
    default_code = 'phone-number-exists'


class EmailExistsException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Уже есть пользователь с такой почтой')
    default_code = 'email-exists'


class PasswordTooSimpleException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Слишком простой пароль')
    default_code = 'password-too-simple'


class PhoneNumberInvalidException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Неверный формат номера телефона. Используйте формат: +77001002030.')
    default_code = 'phone-number-invalid'


class UserNotFoundException(CustomException):
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = _('Пользователь не найден')
    default_code = 'user-not-found'


class MustUsePasswordException(CustomException):
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = _('Используйте пароль для входа')
    default_code = 'must-use-password'


class InviteCodeRequiredException(CustomException):
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = _('Требуется код приглашения')
    default_code = 'invite-code-required'


class InviteCodeNotFoundException(CustomException):
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = _('Неверный код приглашения')
    default_code = 'invite-code-not-found'


class InactiveUserException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Ваш аккаунт недоступен для входа.')
    default_code = 'account-is-inactive'


class InvalidCredentialsException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Невозможно выполнить вход. Пожалуйста, проверьте введенные данные и повторите попытку.')
    default_code = 'invalid_credentials'


class CheckInCoordinatesException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы не указали координаты check in для пользователя с зоной')
    default_code = 'check-in-coordinates'


class CheckInTwiceException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы уже сделали check in')
    default_code = 'check-in-twice'


class TookOffException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы сегодня отпросились')
    default_code = 'today-took-off'


class DayOffException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('У вас выходной')
    default_code = 'day-off'


class EmployeeTooFarFromDepartment(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы не находитесь в радиусе вашего отдела')
    default_code = 'too-far'


class CheckInRequiredException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы еще не сделали check in')
    default_code = 'check-in-required'


class CheckOutTwiceException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Вы уже сделали check out')
    default_code = 'check-out-twice'


class CheckOutExpiredException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Укажите время check out')
    default_code = 'check-out-expired'


class TooEarlyCheckoutException(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Еще рано до check out')
    default_code = 'too-early'


class CompanyAccessDeniedException(CustomException):
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = _('Это не ваша компания.')
    default_code = 'company-access-denied'


class CompanyAlreadyExists(CustomException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Компания с таким названием уже существует')
    default_code = 'company-already-exists'


class UserAlreadyExists(APIException):
    status_code = status.HTTP_423_LOCKED
    default_detail = _('Пользователь с данной электронной почтой уже зарегистрирован в системе')
    default_code = 'user-already-exists'


class ChecklistAssignNotCorrectException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Данный чек-лист вам не назначен')
    default_code = 'not-your-checklist'


class ChecklistNotForThisDayException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Чек-лист не запланирован на этот день')
    default_code = 'checklist-not-for-this-day'


class ChecklistAlreadyCompletedException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Чек-лист уже завершен')
    default_code = 'checklist-already-completed'


class TaskNotFoundException(CustomException):
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = _('Задача не найдена')
    default_code = 'task-not-found'


class TaskNotBelongChecklistException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Задача не принадлежит чек-листу')
    default_code = 'task-not-belong-checklist'


class UnknownErrorException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Неизвестная ошибка')
    default_code = 'unknown-error'


class InvalidDateFormatException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Неправильный формат даты')
    default_code = 'invalid-date-format'


class TaskAlreadyCompletedException(CustomException):
    status_code = status.HTTP_403_FORBIDDEN
    default_detail = _('Данная задача уже выполнена!')
    default_code = 'task-already-completed'


class BoundPointChecklistException(CustomException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = _('Вы не можете установить награду\штраф более чем 100 баллов')
    default_code = 'bound-point-checklist'


class CompanyOtherEmployeeExists(APIException):
    status_code = status.HTTP_404_NOT_FOUND
    default_detail = _('Не удалось найти сотрудника')
    default_code = 'employee-not-found'