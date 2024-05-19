import json
import mimetypes
import os

from django.shortcuts import render,redirect
from django.contrib import messages
from django.contrib.auth.models import User
from ..models import DIARY,DIARY_DETAIL
from datetime import datetime, timedelta
from calendar import monthrange
from django.db.models import Q
from django.http import HttpResponse
import boto3


def get_diary_entries_for_month(year, month):
    start_date = datetime(year, month, 1)
    _, last_day = monthrange(year, month)
    end_date = datetime(year, month, last_day)

    # 범위에 해당하는 데이터 조회
    diary_entries = DIARY.objects.filter(
        date__range=(start_date, end_date)
    )

    emo_list = [entry.emo for entry in diary_entries]

    days_in_month = last_day
    emo_list += [None] * (days_in_month - len(emo_list))

    return {'emo_list':emo_list,'last_day':last_day}

def get_calendar(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    if request.method == "POST":
        selected_date = request.POST.GET('selected_date')
    context = get_diary_entries_for_month(selected_date['year'],selected_date['month'])
    return render(request, 'calendar.html', context['emo_list'],context['last_day'])

def get_date(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    if request.method == "GET":
        date = request.GET.get('date')
        try:
            get_diary(request,user_id,date)
        except Exception as e:
            return HttpResponse("다이어리의 호출을 실패하였습니다. "+str(e),status=500)
    else:
        return


def get_diary(request, user_id,date):
    bucket_name = "freshmanproject"
    diary = DIARY.objects.filter(USER_ID=user_id, DATE=date)
    detail = DIARY_DETAIL.objects.filter(ID=diary.ID)

    # S3 접근을 위한 인증 정보 설정
    s3 = boto3.client('s3')
    try:
        # S3에서 파일 다운로드
        ori_file = s3.get_object(Bucket=bucket_name, Key= diary.ORI_FILE_DIR)
        # 파일의 MIME 타입 가져오기
        content_type_ori = ori_file['ContentType']
        # 파일 데이터 가져오기
        file_content_ori = ori_file['Body'].read()
        feedback_file = s3.get_object(Bucket=bucket_name, Key=detail.FEEDBACK_FILE_DIR)
        content_type_feedback = feedback_file['ContentType']
        file_content_feedback = feedback_file['Body'].read()
        response_data= {
            'emo':diary.EMO,
            'feedback_text': detail.FEEDBACK_TEXT,
            'ori_file': {
                'content_type': content_type_ori,
                'file_content': file_content_ori.decode('utf-8')
            },
            'feedback_file': {
                'content_type': content_type_feedback,
                'file_content': file_content_feedback.decode('utf-8')
            }
        }
        json_response = json.dumps(response_data)
        http_response = HttpResponse(json_response, content_type='application/json')
        return render(request, 'result.html',http_response)
    except Exception as e:
        return HttpResponse("Error retrieving file from S3: " + str(e), status=500)




