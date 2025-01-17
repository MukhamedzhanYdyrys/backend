from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

from auth_user.models import User
from common.models import BaseModel
from config import settings


class RoleChoices(models.IntegerChoices):
    HR = 1, 'HR'
    CO_OWNER = 2, 'Co-owner'
    EMPLOYEE = 3, 'Employee'
    HEAD_OF_DEPARTMENT = 4, 'Head of department'


class Company(BaseModel):
    name = models.CharField(max_length=100)
    invite_code = models.CharField(max_length=10, unique=True)
    years_of_work = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    max_employees_qty = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    owner = models.ForeignKey(to=User, on_delete=models.SET_NULL, null=True, default=None, related_name='owned_companies')
    is_active = models.BooleanField(default=True)
    is_deleted = models.BooleanField(default=False)
    is_main = models.BooleanField(default=False)

    class Meta:
        verbose_name_plural = 'Companies'

    def __str__(self):
        return self.name


class Department(BaseModel):
    name = models.CharField(max_length=100)
    company = models.ForeignKey(to=Company, on_delete=models.CASCADE, related_name='departments')
    is_hr = models.BooleanField(default=False)
    head_of_department = models.ForeignKey(to='companies.Role', on_delete=models.SET_NULL, null=True, blank=True, related_name='head_departments')
    timezone = models.CharField(max_length=64, default=settings.TIME_ZONE)
    start_inaccuracy = models.PositiveIntegerField(default=0)  # minutes
    zones = models.ManyToManyField('Zone', blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['name', 'company'], name='unique name-company'),
        ]

    def __str__(self):
        return f'{self.name} @{self.company}'


class Role(BaseModel):
    company = models.ForeignKey(to=Company, on_delete=models.CASCADE, related_name='roles')
    department = models.ForeignKey(to=Department, on_delete=models.CASCADE, null=True, blank=True, related_name='roles')
    role = models.IntegerField(choices=RoleChoices.choices, default=RoleChoices.EMPLOYEE)
    user = models.OneToOneField(to='auth_user.User', on_delete=models.CASCADE)
    title = models.CharField(max_length=200, default='')
    grade = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(4)])
    checkout_any_time = models.BooleanField(default=True)
    in_zone = models.BooleanField(default=True)
    checkout_time = models.PositiveIntegerField(default=15)  # minutes

    class Meta:
        ordering = ('-created_at',)

    def __str__(self):
        department = self.department or '-'
        return f'{self.user} - {department}'


class Zone(BaseModel):
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='zones')
    address = models.CharField(max_length=255, blank=True)
    latitude = models.DecimalField(max_digits=22, decimal_places=6, default=0, validators=[MinValueValidator(0)])
    longitude = models.DecimalField(max_digits=22, decimal_places=6, default=0, validators=[MinValueValidator(0)])
    radius = models.IntegerField()
    employees = models.ManyToManyField('Role', blank=True, related_name='zones')

    def __str__(self):
        return f'{self.company} - {self.address}'
