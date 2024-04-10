from config.celery import app
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings
from django.http import HttpRequest
from django.contrib.sites.shortcuts import get_current_site
from django.utils.translation import gettext_lazy as _


def get_domain(request: HttpRequest) -> str:
    current_site = get_current_site(request)
    domain_name = current_site.domain
    if 'media.' in domain_name:
        domain_name = domain_name.replace('media.', '')

    protocol = 'https://' if request.is_secure() else 'http://'
    return protocol + domain_name


@app.task
def __send_email(subject: str, to_list: list, template_name: str, context: dict):
    from_mail = settings.EMAIL_HOST_USER
    email_tmp = render_to_string(template_name, context)
    msg = EmailMultiAlternatives(subject, email_tmp, from_mail, to_list)
    msg.attach_alternative(email_tmp, "text/html")
    msg.send()


def send_email(subject: str, to_list: list, template_name: str, context: dict):
    if settings.IS_RUNNING_TESTS:
        return

    if '127.0.0.1' in settings.CURRENT_SITE:
        __send_email(
            subject=subject,
            to_list=to_list,
            template_name=template_name,
            context=context,
        )
    else:
        __send_email.delay(
            subject=subject,
            to_list=to_list,
            template_name=template_name,
            context=context,
        )


def send_welcome_email(email: str, password: str, phone_number: str, user_type: int):
    from auth_user.models import UserTypes
    send_email(
        subject=_('Добро пожаловать!'),
        to_list=[email,],
        template_name='company_registered_notification.html',
        context={
            'domain': settings.CURRENT_SITE,
            'login': email,
            'password': password,
            'phone_number': phone_number,
            'website_access': user_type != UserTypes.EMPLOYEE,
        },
    )
