import json
import mimetypes
import os
from django.shortcuts import render,redirect
from django.contrib import messages
from django.contrib.auth.models import User
from haru.models import DIARY,DIARY_DETAIL
from datetime import datetime, timedelta
from calendar import monthrange
from django.db.models import Q
from django.http import HttpResponse, JsonResponse
import boto3
from django.conf import settings
from time import timezone

def get_diary_entries_for_month(year, month):
    today = timezone.now().date()
    start_date = datetime(year, month, 1)
    _, last_day = monthrange(year, month)
    end_date = datetime(year, month, last_day)

    # 범위에 해당하는 데이터 조회
    diary_entries = DIARY.objects.filter(
        date__range=(start_date, end_date),
        date__lte = today
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
        return redirect('webpage:index')
    if request.method == "POST":
        selected_date = request.POST.get('selected_date')
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
        year = date['year']
        month = date['month']
        day = date['month']

        diary, detail, response = get_diary(request,user_id,date)

        if diary == None and detail == None:
            return response

        res = {
            "emo": diary.EMO,
            'feedback_text': detail.FEEDBACK_TEXT,
            'original': f"haru/voice/{date.year}/{date.month}/{date.day}/original/",
            'feedback': f"haru/voice/{date.year}/{date.month}/{date.day}/feedback/"
        }

        
        return JsonResponse(res) 
 
    else:
        return HttpResponse("Invalid Method", status=405)


def get_diary(request, user_id, date):
    diary_query = DIARY.objects.filter(USER_ID=user_id, DATE=date)
    if diary_query.count() != 1:
        return None, None, HttpResponse(f"Diary on {date} not found", status=404)

    diary = diary_query.first()

    detail_query = DIARY_DETAIL.objects.filter(ID=diary.id)

    if detail_query.count() != 1:
        return None, None, HttpResponse(f"Internal Error: found {detail_query.count()} DIARY_DETAIL for DIARY({date})", status=500)

    detail = detail_query.first()

    return diary, detail, None


def get_voice_file(request, year, month, day, type):
    if request.user.is_authenticated == False:
        return HttpResponse("Login Required", status=403)

    bucket_name = settings.AWS_STORAGE_BUCKET_NAME
    s3 = boto3.client('s3')

    date = {}

    date['year'] = year
    date['month'] = month
    date['month'] = day

    diary, detail, response = get_diary(request, request.user.id, date)

    if diary == None and detail == None:
        return response

    key = ""

    if type == 'original':
        key = diary.ORI_FILE_DIR

    elif type == 'feedback':
        key = detail.FEEDBACK_FILE_DIR

    try:
        voice_file = s3.get_object(Bucket=bucket_name, Key=key)
        voice_data = voice_file.read()

        return HttpResponse(voice_data, content_type="audio/wav")

    except Exception as e:
        return HttpResponse("Error retrieving file from S3: " + str(e), status=500)

