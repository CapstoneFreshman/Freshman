from django import forms
from haru.models import Diary,Diary_detail

class Get_diary(forms.ModelForm):
    class Meta:
        model = Diary
        fields = ['USER_ID', 'DATE', 'EMO', 'TEXT']  # 필드 목록을 필요에 따라 조정합니다.

class Get_detail(forms.ModelForm):
    class Meta:
        model = Diary_detail
        fields = ['FEEDBACK_TEXT','FILE_DIR']