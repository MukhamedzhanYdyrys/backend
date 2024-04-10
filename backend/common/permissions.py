from auth_user.models import User
from companies.models import Company, Role


def has_permission_for_company(user: User, company: Company) -> bool:
    if not user.is_authenticated:
        return False
    if has_owner_permission(user, company):
        return True
    return Role.objects.filter(user=user, company=company).exists()


def has_owner_permission(user: User, company: Company) -> bool:
    if not user.is_authenticated:
        return False
    if company.owner == user:
        return True
    return False