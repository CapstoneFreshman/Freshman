from django.urls import path
from django.contrib.auth import views as auth_views
from . import views


app_name = 'webpage'
urlpatterns =[
    path('', views.index, name='home'),
    path('login/', auth_views.LoginView.as_view(template_name='webpage/login_page.html'), name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('join/',views.join_view, name='join'),
]