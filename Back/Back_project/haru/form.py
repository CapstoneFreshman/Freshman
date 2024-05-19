from django import forms
from .models import DIARY,DIARY_DETAIL

class Get_diary(forms.ModelForm):
    class Meta:
        model = DIARY
        fields = ['EMO']

