from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User


from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from django.contrib.auth import get_user_model
from .models import Haru_setting
import requests

class CustomUserChangeForm(UserChangeForm):

    class Meta:
        model = get_user_model()
        fields = ('email', 'first_name', 'last_name', 'nick_name')


class CustomUserCreationForm(UserCreationForm):

    class Meta(UserCreationForm.Meta):
        model = get_user_model()
        fields = UserCreationForm.Meta.fields + ('email', 'nick_name')

class HaruSetting(requests):
    class Meta(requests):
        model = Haru_setting()
        fields = requests.Meta.fields + ('haru_old', 'haru_style', 'haru_gender')
        
