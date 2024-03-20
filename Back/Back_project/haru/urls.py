from django.urls import path
from django.contrib.auth import views as auth_views
from . import views


app_name = 'webpage'
urlpatterns =[
    path('new_diary/', views.post.new, name='new'),
    path('last_diary/', views.post.record, name='record'),
    path('join/',views.join_view, name='join'),
]