from drf_yasg import openapi


QUERY_DATE = openapi.Parameter(
    'date',
    openapi.IN_QUERY,
    description='date (Example: 2023-12-31)',
    type=openapi.FORMAT_DATE
)

QUERY_DEPARTMENTS = openapi.Parameter(
    'departments',
    openapi.IN_QUERY,
    description='[24,56,...]',
    type=openapi.TYPE_ARRAY,
    items=openapi.Items(type=openapi.TYPE_INTEGER)
)

QUERY_COMPANY = openapi.Parameter(
    'company',
    openapi.IN_QUERY,
    description='company id',
    type=openapi.TYPE_INTEGER
)

QUERY_DEPARTMENT = openapi.Parameter(
    'department',
    openapi.IN_QUERY,
    description='department id',
    type=openapi.TYPE_INTEGER
)

QUERY_INVITE_CODE = openapi.Parameter(
    'invite_code',
    openapi.IN_QUERY,
    description='Invite code (Example: 123456)',
    type=openapi.TYPE_STRING
)
