import json
import mimetypes
import os
from django.shortcuts import render,redirect
from django.contrib import messages
from webpage.models import User
from haru.models import DIARY,DIARY_DETAIL
from datetime import datetime, timedelta
from calendar import monthrange
from django.db.models import Q
from django.http import HttpResponse, JsonResponse
import boto3
from django.conf import settings
from time import timezone

def get_diary_entries_for_month(user_id, year, month):
    user = User.objects.get(id=user_id)
    start_date = datetime(year, month, 1)
    _, end_day = monthrange(year, month)
    end_date = datetime(year, month, end_day)
    start_day = start_date.day

    diary_query = DIARY.objects.filter(DATE__year=str(year),
                                       DATE__month=str(month),
                                       USER_ID=user)

    pairs = []
    
    for i in range(start_day, end_day+1):
        diary = diary_query.filter(DATE__day=str(i))
        if diary.count() != 1:
            continue

        diary = diary.first()

        pairs.append({
            "day": i,
            "emo": diary.EMO
        })

    return pairs


def get_calendar(request, year, month):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        return HttpResponse("Login First", status=403)
    pairs = get_diary_entries_for_month(user_id, year, month)
    return JsonResponse({'pairs' : pairs})

def get_date(request, year, month, day):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request, "로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    if request.method == "GET":

        date = datetime(year,month,day)

        diary, detail, response = get_diary(request,user_id,date)

        if diary == None and detail == None: #for test
            res = {
                "emo": "테스트 감정",
                'short_text': "Test short text",
                'feedback_text': "테스트 피드백 텍스트",
                'original': f"haru/voice/{date.year}/{date.month}/{date.day}/original/",
                'feedback': f"haru/voice/{date.year}/{date.month}/{date.day}/feedback/"
            }

        else:
            res = {
                "emo": diary.EMO,
                'short_text': detail.SHORT_TEXT,
                'feedback_text': detail.FEEDBACK_TEXT,
                'original': f"haru/voice/{date.year}/{date.month}/{date.day}/original/",
                'feedback': f"haru/voice/{date.year}/{date.month}/{date.day}/feedback/"
            }

        
        return JsonResponse(res) 
 
    else:
        return HttpResponse("Invalid Method", status=405)


def get_diary(request, user_id, date):
    user = User.objects.get(id=user_id)
    print(date)
    diary_query = DIARY.objects.filter(USER_ID=user, DATE__year=date.year, DATE__month=date.month, DATE__day=date.day)
    if diary_query.count() == 0:
        return None, None, HttpResponse(f"Diary on {date} not found", status=404)

    diary = diary_query.first()

    detail_query = DIARY_DETAIL.objects.filter(ID=diary.id)

    if detail_query.count() != 1:
        print(f"Internal Error: found {detail_query.count()} DIARY_DETAIL for DIARY({date})")
        return None, None, HttpResponse(f"Internal Error: found {detail_query.count()} DIARY_DETAIL for DIARY({date})", status=500)

    detail = detail_query.first()

    return diary, detail, None


def get_voice_file(request, year, month, day, type):
    if request.user.is_authenticated == False:
        return HttpResponse("Login Required", status=403)


    date = datetime(year, month, day)

    diary, detail, response = get_diary(request, request.user.id, date)

    print(diary)
    print(detail)
    print(response)

    if diary == None or detail == None or diary.ORI_FILE_DIR == "Test Original Path" or detail.FEEDBACK_FILE_DIR == "Test Feedback Path":#for test
        from Back_project.settings import MEDIA_ROOT
        if type == "original" or type == "feedback":
            with open(f"{MEDIA_ROOT}/{type}.wav", "rb") as sample:
                response =  HttpResponse(sample.read(), content_type="audio/wav")

        else:
            response = HttpResponse(f"Diary not found + invalid type({type})", status="404")
            
        return response

    key = ""

    if type == 'original':
        key = diary.ORI_FILE_DIR

    elif type == 'feedback':
        key = detail.FEEDBACK_FILE_DIR

    try:
        bucket_name = settings.AWS_STORAGE_BUCKET_NAME
        s3 = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_S3_REGION_NAME
            )
        voice_file = s3.get_object(Bucket=bucket_name, Key=key)
        voice_data = voice_file['Body'].read()

        return HttpResponse(voice_data, content_type="audio/wav")

    except Exception as e:
        print(str(e))
        return HttpResponse("Error retrieving file from S3: " + str(e), status=500)
