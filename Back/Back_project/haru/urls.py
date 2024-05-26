from django.urls import path
from django.contrib.auth import views as auth_views
from haru.views import post, get

app_name = 'haru'
urlpatterns =[
    path('post/', post.record, name='post'),
    path('calendar/', get.get_calendar,name='get_calendar'),
    path('get/', get.get_date, name='get'),

]