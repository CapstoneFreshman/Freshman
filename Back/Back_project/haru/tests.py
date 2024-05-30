from django.test import TestCase
from datetime import datetime
from haru.models import DIARY,DIARY_DETAIL
from webpage.models import User
from calendar import monthrange
import pytz
from random import choice

# Create your tests here.

def create_sample_diary(user_id, year, month):
    user = User.objects.get(id=user_id)
    emotions = ["기쁨", "슬픔", "분노", "무감정"]
    start_date = datetime(year, month, 1)
    _, end_day = monthrange(year, month)
    end_date = datetime(year, month, end_day)
    start_day = start_date.day

    for i in range(start_day, end_day+1):
        try:
            diary = DIARY(
                USER_ID=user,
                DATE=datetime(year, month, i),
                EMO=choice(emotions),
                ORI_FILE_DIR="Test Original Path"
            )
            diary.save()

            detail = DIARY_DETAIL(
                ID=diary.id,
                SHORT_TEXT="Test Short Text",
                FEEDBACK_TEXT="Test FeedBack Test",
                FEEDBACK_FILE_DIR="Test Feedback Path"
            )

            detail.save()

        except Exception as e:
            print(str(e))
            return


def get_date_emotion_pairs(user_id, year, month):
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

    print(pairs)
