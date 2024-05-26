from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User


from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from django.contrib.auth import get_user_model

import requests

from haru.models import Haru_setting

class CustomUserChangeForm(UserChangeForm):

    class Meta:
        model = get_user_model()
        fields = ('email', 'first_name', 'last_name', 'nick_name')


class CustomUserCreationForm(UserCreationForm):

    class Meta(UserCreationForm.Meta):
        model = get_user_model()
        fields = UserCreationForm.Meta.fields + ('email', 'nick_name')


class HaruSettingChangeForm(forms.ModelForm):

    class Meta:
        model = Haru_setting
        fields = [
            "HARU_OLD",
            "HARU_STYLE",
            "HARU_GENDER"
        ]
        labels = {
            'HARU_OLD_FIELD' : "연령대",
            'HARU_STYLE_FIELD' : "발화 스타일",
            "HARU_GENDER_FIELD" : "성별"
        }
        widgets = {
            'HARU_OLD' : forms.RadioSelect(choices=Haru_setting.HARU_OLD_CHOICE),
            'HARU_STYLE' : forms.RadioSelect(choices=Haru_setting.HARU_STYLE_CHOICE),
            'HARU_GENDER' : forms.RadioSelect(choices=Haru_setting.HARU_GENDER_CHOICE)
        }
