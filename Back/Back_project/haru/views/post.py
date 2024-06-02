from django.shortcuts import render, redirect
from haru.views.upload_file_to_s3 import upload_wav_to_s3
from haru.models import DIARY
from django.http import HttpResponse, HttpResponseBadRequest,JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
import json
import pytz

@csrf_exempt
def record(request):
    # if not request.user.is_authenticated:
    #     return HttpResponseBadRequest("로그인 오류")
    #
    # user_id = request.user.id


    user_id = '1'
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
        path_tag = f"ori_{user_id}_{year}{month}{day}{hour}{minute}{second}.wav"

        if not emo or not wav_file:
            return HttpResponseBadRequest("필수 필드가 누락되었습니다.")

        try:

            response = upload_wav_to_s3(request,path_tag)
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

        return HttpResponse("일기 작성 완료.")
    else:
        return HttpResponseBadRequest("잘못된 요청 방법")
