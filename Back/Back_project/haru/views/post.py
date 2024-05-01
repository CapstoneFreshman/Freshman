from django.shortcuts import render
from django.contrib import messages
from haru.models import Diary
from . import temp_voice
from . import api_connector

# Create your views here.
def record(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    user_diary_set = Diary.objects.filter(id=user_id)


def call_haru(request):
    if request.method == ' POST':
        voice_file = request.FILES['voice_file']
        voice_path = temp_voice.temp_file(voice_file)
        full_text = api_connector.transcribe_audio(voice_path)
        short_text = api_connector.summarize_text(full_text)
        feedback_text = api_connector.feedback_text(short_text)
        return render(request, 'upload_success.html')
    return render(request, 'upload_form.html')









