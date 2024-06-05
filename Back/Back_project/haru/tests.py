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


#test with 161
def test_voice_synth(diary_id):
    import requests
    from Back_project.settings import FLASK_IP

    json_data = {
                'gender' : 1,
                'age_group': 2,
                'speech_style': 2,
                'emotion': "기쁨",
                'diary_id': diary_id,
                'time_tag': "aaa_20240603132928",
                'ori_file_dir' : "ORI_FILE/ori_aaa_20240603132928.wav",
                'client_ip' : "http://175.125.148.178:2871" 
            }

    print(requests.post(f"http://{FLASK_IP}:9000/upload", data = json_data))


def test_timezone():
    from django.utils import timezone
    from haru.models import DIARY
    from webpage.models import User

    KST = pytz.timezone('Asia/Seoul')
    UTC = pytz.timezone('UTC')
    now_utc = timezone.now().replace(tzinfo=UTC)
    now_kst = now_utc.astimezone(KST)
    date = now_kst

    new_diary = DIARY(
        USER_ID=User.objects.get(id=2),
        DATE=date,
        EMO="Timezone Test",
        ORI_FILE_DIR="TimezoneTest"
    )

    new_diary.save()



def test_get_voice():
    from Back_project import settings
    import boto3

    key = "ORI_FILE/ori_aaa_20240605133135.wav"
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

        with open("/mnt/d/test.wav", 'wb') as wav:
            wav.write(voice_data)

    except Exception as e:
        print(str(e))

