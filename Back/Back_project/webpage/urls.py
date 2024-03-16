from django.urls import path
from django.contrib.auth import views as auth_views

app_name = 'webpage'
urlpatterns =[
    path('login/', auth_views.LoginView.as_view(), name='login'),
    path('logout/',views.logout_view,name='logout'),
]