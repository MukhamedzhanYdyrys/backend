from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.translation import gettext_lazy as _

from auth_user.models import User
from common.models import BaseModel


class ReasonType(models.IntegerChoices):
    CUSTOM = 1, _('Другой.')
    ABSENT = 10, _('Отсутствует.')
    LATE_CHECK_IN = 2, _('Опоздание.')
    LATE_CHECK_OUT = 3, _('Позднее завершение дня.')

    TRELLO_MISSED_DEADLINE_EASY = 4, _("Не выполнил вовремя задачу легкой сложности.")
    TRELLO_MISSED_DEADLINE_MEDIUM = 5, _("Не выполнил вовремя задачу средней сложности.")
    TRELLO_MISSED_DEADLINE_HARD = 6, _("Не выполнил вовремя задачу высокой сложности.")
    TRELLO_COMPLETED_EASY = 7, _("Награда за выполнение задачи легкой сложности.")
    TRELLO_COMPLETED_MEDIUM = 8, _("Награда за выполнение задачи средней сложности.")
    TRELLO_COMPLETED_HARD = 9, _("Награда за выполнение задачи высокой сложности.")

    CHECKLIST_EXECUTOR_REWARD = 11, _("Награда исполнителю чеклиста.")
    CHECKLIST_EXECUTOR_PENALTY_LATE = 12, _("Штраф исполнителю за позднее исполнение чеклиста.")
    CHECKLIST_EXECUTOR_PENALTY_NOT_COMPLETED = 13, _("Штраф исполнителю за невыполнение чеклиста.")
    CHECKLIST_INSPECTOR_REWARD = 14, _("Награда проверяющему чеклиста.")
    CHECKLIST_INSPECTOR_PENALTY_LATE = 15, _("Штраф проверяющему за несвоевременную проверку чеклиста.")
    CHECKLIST_INSPECTOR_PENALTY_NOT_COMPLETED = 16, _("Штраф проверяющему за игнорирование проверки чеклиста.")

    @staticmethod
    def penalties():
        return [
            ReasonType.ABSENT,
            ReasonType.LATE_CHECK_IN,
            ReasonType.LATE_CHECK_OUT,
            ReasonType.TRELLO_MISSED_DEADLINE_EASY,
            ReasonType.TRELLO_MISSED_DEADLINE_MEDIUM,
            ReasonType.TRELLO_MISSED_DEADLINE_HARD,
            ReasonType.CHECKLIST_EXECUTOR_PENALTY_LATE,
            ReasonType.CHECKLIST_EXECUTOR_PENALTY_NOT_COMPLETED,
            ReasonType.CHECKLIST_INSPECTOR_PENALTY_LATE,
            ReasonType.CHECKLIST_INSPECTOR_PENALTY_NOT_COMPLETED,
        ]


class Reason(BaseModel):
    name = models.CharField(max_length=255)  # only for the custom type
    type = models.IntegerField(choices=ReasonType.choices, default=ReasonType.CUSTOM)
    score = models.SmallIntegerField(validators=[MinValueValidator(-100), MaxValueValidator(100)])
    company = models.ForeignKey('companies.Company', on_delete=models.CASCADE, related_name='reasons')

    def __str__(self):
        return f'{self.name}: {self.score}'


class Score(BaseModel):
    role = models.ForeignKey('companies.Role', on_delete=models.CASCADE, related_name='scores')
    reason_type = models.IntegerField(choices=ReasonType.choices, default=ReasonType.CUSTOM)
    name = models.CharField(max_length=255, blank=True)
    points = models.SmallIntegerField(validators=[MinValueValidator(-100), MaxValueValidator(100)])
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, null=True)

    def __str__(self):
        return f'{self.role}: {self.name} {self.points}'