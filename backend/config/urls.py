import debug_toolbar
import environ

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from drf_yasg import openapi
from drf_yasg.views import get_schema_view
from rest_framework import permissions

import auth_user.views

env = environ.Env()
environ.Env.read_env()


schema_view = get_schema_view(
    openapi.Info(
        title="Beka API",
        default_version='v1',
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
    url='https://workpunc.xyz'
)

urlpatterns = [
    path('api/', include('config.api_urls')),
    path('django-admin/', admin.site.urls),
]

# if settings.DEBUG:

urlpatterns += [
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='swagger'),
] + static(
    settings.MEDIA_URL, document_root=settings.MEDIA_ROOT
) + static(
    settings.STATIC_URL, document_root=settings.STATIC_ROOT
)
try:
    urlpatterns += [path('__debug__/', include(debug_toolbar.urls))]
except ImportError:
    pass
