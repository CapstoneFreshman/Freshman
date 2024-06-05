from django.shortcuts import render, redirect
from haru.views.upload_file_to_s3 import upload_wav_to_s3
from webpage.models import User
from haru.models import DIARY,DIARY_DETAIL,Haru_setting
from django.http import HttpResponse, HttpResponseBadRequest,JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
import json
import pytz
import requests
from datetime import datetime
from django.conf import settings
import socket

def set_tag(date,user_id):

    year = date.year
    month = "{:02}".format(date.month)
    day = "{:02}".format(date.day)
    hour = "{:02}".format(date.hour)
    minute = "{:02}".format(date.minute)
    second = "{:02}".format(date.second)
    time_tag = f"{user_id}_{year}{month}{day}{hour}{minute}{second}"
    return time_tag

@csrf_exempt
def record(request):
    if not request.user.is_authenticated:
        return HttpResponseBadRequest("로그인 오류")
    
    user_id = User.objects.get(id=request.user.id)
    if request.method == "POST":
        KST = pytz.timezone('Asia/Seoul')
        UTC = pytz.timezone('UTC')
        now_utc = timezone.now().replace(tzinfo=UTC)
        now_kst = now_utc.astimezone(KST)
        date = now_kst

        emo = request.POST.get('EMO')
        wav_file = request.FILES.get('wav_file')
        time_tag = set_tag(date,user_id)
        path_tag = f"ori_{time_tag}.wav"
        print(emo, wav_file)

        if not emo or not wav_file:
            return HttpResponseBadRequest("필수 필드가 누락되었습니다.")

        try:
            response = upload_wav_to_s3(request,"ORI_FILE",path_tag)
            if response.status_code == 200:
                response_data = json.loads(response.content)
                ori_file_path = response_data.get('url')
            else:
                return HttpResponseBadRequest("파일 업로드 실패")
        except Exception as e:
            return HttpResponseBadRequest(f"파일 업로드 예외 발생: {e}")



        new_diary = DIARY(
            USER_ID=user_id,
            DATE=date,
            EMO=emo,
            ORI_FILE_DIR=ori_file_path
        )
        new_diary.save()
        id = new_diary.id

        haru_info = Haru_setting.objects.filter(USER_ID=request.user.id)

        json_data = {}

        if haru_info.count() != 1:
            print(f"Cannot find HARU_SETTING for user id({user_id})")
            json_data = {
                'gender' : 1,
                'age_group': 2,
                'speech_style': 2,
                'emotion': emo,
                'diary_id': id,
                'time_tag': time_tag,
                'ori_file_dir' : ori_file_path,
                'client_ip' : "http://175.125.148.178:2871" 
            }

        else:
            haru_info = haru_info.first()
            json_data = {
                'gender' : haru_info.HARU_GENDER,
                'age_group': haru_info.HARU_OLD,
                'speech_style': haru_info.HARU_STYLE,
                'emotion': emo,
                'diary_id': id,
                'time_tag': time_tag,
                'ori_file_dir' : ori_file_path,
                'client_ip' : "http://175.125.148.178:2871" 
            }



        flask_server_url = f'http://{settings.FLASK_IP}:9000/upload'

        print(json_data)
        new_response = requests.post(flask_server_url, data = json_data)
        print(new_response)
        #send_request_flask(new_response)
        return HttpResponse("일기 작성 완료.")
    else:
        return HttpResponseBadRequest("잘못된 요청 방법")

def send_request_flask(response):
    if response.status_code != 200:
        return JsonResponse({'error': 'Failed to send data to Flask server'}, status=response.status_code)

    return JsonResponse(response.json(), status=response.status_code)

@csrf_exempt
def build_diary(request):
    if request.method == "POST":
        feedback_text = request.POST.get('feedback_text')
        short_text = request.POST.get('short_text')
        feedback_file = request.FILES.get('wav_file')
        id = request.POST.get('id')
        time_tag = request.POST.get('time_tag')
        path_tag = f"feedback_{time_tag}.wav"
        response = upload_wav_to_s3(request,"FEEDBACK_FILE",path_tag)
        if response.status_code == 200:
            response_data = json.loads(response.content)
            feedback_file_path = response_data.get('url')
        else:
            return HttpResponseBadRequest("파일 업로드 실패")

        new_detail = DIARY_DETAIL(
            ID=id,
            SHORT_TEXT=short_text,
            FEEDBACK_TEXT=feedback_text,
            FEEDBACK_FILE_DIR=feedback_file_path
        )
        new_detail.save()
    return HttpResponse("일기 상세 작성 완료.")