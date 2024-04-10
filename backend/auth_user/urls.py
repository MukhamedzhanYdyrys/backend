from django.urls import path
from auth_user import views


urlpatterns = [
    path('auth/register/', views.RegisterApi.as_view({'post': 'post'}), name='register'),
    path('auth/register/get-departments/', views.GetDepartmentsApi.as_view(), name='register-get-departments'),

    path('auth/sms/send/', views.SendSmsApi.as_view(), name='send_sms'),
    path('auth/sms/verify/', views.VerifySmsApi.as_view(), name='verify_sms'),
    path('auth/sms/set-password/', views.SetPasswordViaSmsApi.as_view(), name='set_password_via_sms'),
    path('auth/token/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', views.CustomTokenRefreshView.as_view(), name='token_refresh'),
    path('auth/change-password/', views.ChangePasswordView.as_view({'post': 'change_password'}), name='change-password'),

    path('profile/employee/', views.UserProfileView.as_view({'get': 'get', 'patch': 'update'}), name='user-profile'),
    path('profile/owner/', views.OwnerProfileView.as_view({'get': 'get', 'patch': 'update'}), name='owner-profile'),
]