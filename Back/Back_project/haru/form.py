from django import forms
from haru.models import Diary,Diary_detail

class Get_diary(forms.ModelForm):
    class Meta:
        model = Diary
        fields = ['USER_ID', 'DATE', 'EMO', 'ORI_FILE_DIR']

class Get_detail(forms.ModelForm):
    class Meta:
        model = Diary_detail
        fields = ['SHORT_TEXT','FEEDBACK_TEXT','FEEDBACK_FILE_DIR']