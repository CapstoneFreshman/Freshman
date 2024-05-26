from django.shortcuts import render, redirect
from haru.views.upload_file_to_s3 import upload_wav_to_s3
from haru.models import DIARY,DIARY_DETAIL,Haru_setting
from django.http import HttpResponse, HttpResponseBadRequest,JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
import json
import pytz
import requests
@csrf_exempt
def record(request):
    if not request.user.is_authenticated:
        return HttpResponseBadRequest("로그인 오류")

    user_id = request.user.id

    if request.method == "POST":
        KST = pytz.timezone('Asia/Seoul')
        UTC = pytz.timezone('UTC')
        now_utc = timezone.now().replace(tzinfo=UTC)
        now_kst = now_utc.astimezone(KST)
        emo = request.POST.get('EMO')
        wav_file = request.FILES.get('wav_file')
        date = now_kst
        year = date.year
        month = "{:02}".format(date.month)
        day = "{:02}".format(date.day)
        hour = "{:02}".format(date.hour)
        minute = "{:02}".format(date.minute)
        second = "{:02}".format(date.second)
        time_tag = f"{user_id}_{year}{month}{day}{hour}{minute}{second}"
        path_tag = f"ori_{time_tag}.wav"

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
            USER_ID_id=user_id,
            DATE=date,
            EMO=emo,
            ORI_FILE_DIR=ori_file_path
        )
        new_diary.save()
        id = new_diary.id
        haru_info = Haru_setting.objects.filter(ID=user_id)
        flask_server_url = 'http://127.0.0.1:5001/receive'
        files = {
            'file': (wav_file.name, wav_file.read(), 'audio/wav')
        }
        json_data = {
            'data': json.dumps({
                'gender' : haru_info.HARU_GENDER,
                'age_group' : haru_info.HARU_OLD,
                'speech_style' : haru_info.HARU_STYLE,
                'emotion' : emo,
                'diary_id' : id,
                'user_id' : user_id,
                'time_tag' : time_tag
            })
        }
        new_response = requests.post(flask_server_url,file = files,data = json_data)
        send_request_flask(new_response)
        return HttpResponse("일기 작성 완료.")
    else:
        return HttpResponseBadRequest("잘못된 요청 방법")

def send_request_flask(response):
    if response.status_code != 200:
        return JsonResponse({'error': 'Failed to send data to Flask server'}, status=response.status_code)

    return JsonResponse(response.json(), status=response.status_code)


def build_diary(request):
    if request.method == "POST":
        feedback_text = request.POST.get('feedback_text')
        short_text = request.POST.get('short_text')
        feedback_file = request.FILES.get('feedback_file')
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

