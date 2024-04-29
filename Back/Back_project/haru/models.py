from django.db import models


# Create your models here.
class Diary(models.Model):
    USER_ID = models.IntegerField()
    DATE = models.DateTimeField(null=True,blank=True)
    EMO = models.CharField(max_length=30)
    TEXT = models.TextField()

    def GET_USER_ID(self):
        return self.USER_ID
    def GET_DATE(self):
        return self.DATE
    def GET_TEXT(self):
        return self.TEXT
    def GET_EMO(self):
        return self.EMO

class Diary_detail(models.Model):
    FEEDBACK_TEXT = models.TextField()
    FILE_DIR = models.CharField(max_length=300)

    def GET_FEEDBACK_TEXT(self):
        return self.FEEDBACK_TEXT
    def GET_FILE_DIR(self):
        return self.FILE_DIR


class Haru_setting(models.Model):
    USER_ID = models.IntegerField(primary_key=True)

    # haru age values
    # TODO
    # 1. define enum for HARU_OLD
    # 2. implement validate_old

    HARU_OLD = models.IntegerField()

    # haru style values
    HARU_STYLE_MONOlOGUE = 0 #독백체
    HARU_STYLE_DIALOGUE = 1 #대화체
    HARU_STYLE_NARRATE = 2 # 구연체
    HARU_STYLE_BROADCAST =3 # 중계체
    HARU_STYLE_KIND = 4 # 친절체
    HARU_STYLE_ANIME = 5 # 씹덕체
    HARU_STYLE_RECITE = 6 # 낭독체

    HARU_STYLE = models.IntegerField()

    # haru gender values
    HARU_GENDER_MALE = 0
    HARU_GENDER_FEMALE = 1

    HARU_GENDER = models.IntegerField()



    #create default Haru_settings
    @classmethod
    def create(cls, user_id):
        setting = cls(
            USER_ID=user_id,
            HARU_OLD = 2,
            HARU_STYLE = Haru_setting.HARU_STYLE_DIALOGUE,
            HARU_GENDER = Haru_setting.HARU_GENDER_MALE
        )
        return setting


    def validate_style(self, style):
        return (self.HARU_STYLE_MONOLOGUE <= style) and (style <= self.HARU_STYLE_RECITE)

    def validate_gender(self, gender):
        return (gender == 0) or (gender == 1)

    def validate_old(self, old):
        raise Exception("not implemented yet")