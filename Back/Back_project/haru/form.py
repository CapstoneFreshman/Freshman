from django import forms
from .models import DIARY
from time import timezone

class Get_diary(forms.ModelForm):
    wav_file = forms.FileField()

    class Meta:
        model = DIARY
        fields = ['EMO']

    def __init__(self, *args, **kwargs):
        self.user_id = kwargs.pop('user_id', None)  # user_id를 받아서 인스턴스 변수로 저장
        super().__init__(*args, **kwargs)

    def clean(self):
        cleaned_data = super().clean()
        if not self.user_id:
            raise forms.ValidationError("User ID is required.")
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        if self.user_id:
            instance.user_id = self.user_id  # ForeignKey 필드에 직접 설정
        instance.date = timezone.now()
        instance.ori_file_dir = 'path/to/file'
        if commit:
            instance.save()
        return instance