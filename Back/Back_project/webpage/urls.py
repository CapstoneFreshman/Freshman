from django.urls import path
from django.contrib.auth import views as auth_views
from . import views


app_name = 'webpage'
urlpatterns =[
    path('', views.index, name='index'),
    #path('login/', auth_views.LoginView.as_view(template_name='webpage/login_page.html'), name='login'),
    path('login/', views.api_login, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('join/',views.join_view, name='join'),
    path('haru_setting/', views.haru_setting_view, name='haru_setting'),
    path('profile/', views.profile_view, name='profile'),
    path('csrf_token/', views.csrf_token_view, name="csrf_token")
]