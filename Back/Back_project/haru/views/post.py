from django.shortcuts import render,redirect
from django.contrib import messages
from django.contrib.auth.models import User
from ..models import DIARY,DIARY_DETAIl
from django.http import HttpResponse
from datetime import datetime
from . import temp_voice
from . import api_connector
from ..form import Get_diary,Get_detail

# Create your views here.
def record(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    new_diary = DIARY.objects.all()
    if request.method == "POST":
        date = datetime.now()
        emo = request.POST['emo']
        
        if form.is_valid():
            form.save()


            return redirect('webpage:index')
    else:
        form = CustomUserCreationForm()


def call_haru(request):
    if request.method == ' POST':
        voice_file = request.FILES['voice_file']
        voice_path = temp_voice.temp_file(voice_file)
        full_text = api_connector.transcribe_audio(voice_path)
        short_text = api_connector.summarize_text(full_text)
        feedback_text = api_connector.feedback_text(short_text)
        return render(request, 'upload_success.html')
    return render(request, 'upload_form.html')









