import random

from django.db import models
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin
from django.core.validators import MaxValueValidator, MinValueValidator
from django.utils.timezone import now
from datetime import timedelta, datetime

from imagekit import processors
from imagekit.models import ProcessedImageField
from auth_user.tasks import send_welcome_email
from common.dates import server_now
from common.models import BaseModel
from common.exceptions import EmailExistsException


class UserManager(BaseUserManager):

    def create_user(self, **extra_fields):
        """
        Creates a new user, 'password' must be hashed (use the make_password method)
        """
        email = extra_fields.get('email')
        if email:
            email = email.strip().lower()
            extra_fields['email'] = email
            if User.objects.filter(email=email).exists():
                raise EmailExistsException()

        extra_fields['type'] = extra_fields.get('type', UserTypes.EMPLOYEE)

        user = self.model.objects.create(**extra_fields)

        if not extra_fields.get('password'):
            password = self.model.objects.make_random_password()
            user.set_password(password)
            user.save(update_fields=['password'])
            user.send_mail_invitation(password=password)

        return user

    def create_superuser(self, email, password, **extra_fields):
        """
        Create and save a SuperUser with the given email and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        user = self.model(email=email.lower(), **extra_fields)
        user.set_password(password)
        user.save()
        return user


class AssistantTypes(models.IntegerChoices):
    NON_ASSISTANT = 0, 'Non assistant'
    MARKETING = 1, 'Marketing-sales'
    PRODUCTION_WORKERS = 2, 'Production workers'


class PendingUser(BaseModel):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    middle_name = models.CharField(max_length=50, blank=True)
    email = models.EmailField(max_length=70)
    phone_number = models.CharField(max_length=32)
    password_hash = models.CharField('password', max_length=128)
    department = models.ForeignKey(to='companies.Department', on_delete=models.CASCADE, related_name='pending_users')
    avatar = ProcessedImageField(
        upload_to='avatar/',
        processors=[processors.Transpose()],  # transpose - to fix the 90˚ rotation issue
        format='WEBP',
        options={'quality': 60},
        null=True,
        blank=True
    )
    
    @property
    def full_name(self):
        full_name = f"{self.last_name or ''} {self.first_name or ''}".strip()
        return f"{full_name} {self.middle_name or ''}".strip()


class UserTypes(models.IntegerChoices):
    UNKNOWN = 0, 'no_role'
    OWNER = 1, 'owner'
    CO_OWNER = 2, 'co-owner'
    EMPLOYEE = 3, 'employee'
    HR = 4, 'hr'
    ASSISTANT_MARKETING = 5, 'admin_marketing'
    ASSISTANT_PRODUCTION_WORKERS = 6, 'admin_production_worker'
    PARTNER = 7, 'partner'


class User(AbstractBaseUser, PermissionsMixin):
    type = models.PositiveSmallIntegerField(choices=UserTypes.choices, default=UserTypes.UNKNOWN)
    owner = models.ForeignKey(to='self', on_delete=models.SET_NULL, null=True, blank=True)
    email = models.EmailField(max_length=70, unique=True)
    email_new = models.EmailField(max_length=70, null=True, blank=True)
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    middle_name = models.CharField(max_length=50, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)
    avatar = ProcessedImageField(
        upload_to='avatar/',
        processors=[processors.Transpose()],  # transpose - to fix the 90˚ rotation issue
        format='WEBP',
        options={'quality': 60},
        null=True,
        blank=True
    )
    is_superuser = models.BooleanField(default=False)
    is_admin = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    assistant_type = models.PositiveSmallIntegerField(
        choices=AssistantTypes.choices,
        default=AssistantTypes.NON_ASSISTANT,
        blank=True
    )
    selected_company = models.ForeignKey(to='companies.Company', on_delete=models.SET_NULL, null=True, blank=True)
    language = models.CharField(max_length=10, default='ru')

    USERNAME_FIELD = 'email'

    @property
    def full_name(self):
        full_name = f"{self.last_name or ''} {self.first_name or ''}".strip()
        return f"{full_name} {self.middle_name or ''}".strip()

    objects = UserManager()

    def send_mail_invitation(self, password: str) -> None:
        try:
            send_welcome_email(self.email, password, self.phone_number, self.type)
        except Exception as e:
            print('error')

    def __str__(self):
        return self.email

    class Meta:
        # todo: delete?
        verbose_name = 'Пользователь'
        verbose_name_plural = 'Пользователи'


class ResetPasswordToken(BaseModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=False, blank=False)
    token = models.CharField(max_length=32, null=False, blank=False)

    @staticmethod
    def exp_date() -> datetime:
        return server_now() - timedelta(minutes=15)


class OtpToken(BaseModel):
    token = models.CharField(max_length=32)
    code = models.CharField(max_length=8)
    phone_number = models.CharField(max_length=32)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    company = models.ForeignKey('companies.Company', on_delete=models.CASCADE, null=True, blank=True)
    verified = models.BooleanField(default=False)
    action = models.CharField(max_length=50)

    @staticmethod
    def exp_date() -> datetime:
        return server_now() - timedelta(hours=1)
