from django.shortcuts import render,redirect
from django.contrib import messages
from django.contrib.auth.models import User

from .upload_file_to_s3 import upload_wav_to_s3
from ..models import DIARY,DIARY_DETAIl
from django.http import HttpResponse,HttpResponseBadRequest
from datetime import datetime
from . import temp_voice
from . import api_connector
from ..form import Get_diary

# Create your views here.
def record(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    diary = DIARY.objects.all()
    if request.method == "POST":
        form = Get_diary(request.POST)
        if form.is_valid():
            form.save()
            emo = form.cleaned_data.get('EMO')
        date = datetime.now()
        response = upload_wav_to_s3(request)
        if response.status_code == 200:
            ori_file_path = response.json()['url']
            new_diary = DIARY.objects.create(
                user_id=user_id,
                date=date,
                emo=emo,
                ori_file_path=ori_file_path
            )
            new_diary.save()
            return HttpResponse("일기 작성 완료.")
        else:
            # 업로드 실패 시, 에러 처리
            return HttpResponseBadRequest("음성 파일 업로드에 실패하였습니다.")
    else:
        return


def call_haru(request):
    if request.method == ' POST':
        voice_file = request.FILES['voice_file']
        voice_path = temp_voice.temp_file(voice_file)
        full_text = api_connector.transcribe_audio(voice_path)
        short_text = api_connector.summarize_text(full_text)
        feedback_text = api_connector.feedback_text(short_text)
        return render(request, 'upload_success.html')
    return render(request, 'upload_form.html')









