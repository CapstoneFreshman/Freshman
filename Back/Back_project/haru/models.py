from django.db import models
from webpage.models import User

# Create your models here.
class DIARY(models.Model):
    USER_ID = models.ForeignKey(User, on_delete=models.CASCADE)
    DATE = models.DateTimeField(null=True,blank=True)
    EMO = models.CharField(max_length=30)
    ORI_FILE_DIR = models.TextField()

    def GET_USER_ID(self):
        return self.USER_ID
    def GET_DATE(self):
        return self.DATE
    def GET_EMO(self):
        return self.EMO
    def GET_ORI_FILE_DIR(self):
        return self.ORI_FILE_DIR

class DIARY_DETAIL(models.Model):
    ID = models.IntegerField(primary_key=True)
    SHORT_TEXT = models.TextField()
    FEEDBACK_TEXT = models.TextField()
    FEEDBACK_FILE_DIR = models.TextField()

    def GET_SHORT_TEXT(self):
        return self.SHORT_TEXT
    def GET_FEEDBACK_TEXT(self):
        return self.FEEDBACK_TEXT
    def GET_FEEDBACK_FILE_DIR(self):
        return self.FEEDBACK_FILE_DIR
    def GET_FILE_DIR(self):
        return self.FILE_DIR


class Haru_setting(models.Model):
    USER_ID = models.IntegerField(primary_key=True)

    HARU_OLD_YOUTH = 0
    HARU_OLD_TEENAGER = 1
    HARU_OLD_ADULT = 2
    HARU_OLD_SENIOR = 3

    HARU_OLD_CHOICE = {
        HARU_OLD_YOUTH : '유년층',
        HARU_OLD_TEENAGER : '청소년층',
        HARU_OLD_ADULT : '성인층',
        HARU_OLD_SENIOR : '노년층'
    }

    HARU_OLD = models.IntegerField()

    # haru style values
    HARU_STYLE_MONOlOGUE = 0 #독백체
    HARU_STYLE_DIALOGUE = 1 #대화체
    HARU_STYLE_NARRATE = 2 # 구연체
    HARU_STYLE_BROADCAST =3 # 중계체
    HARU_STYLE_KIND = 4 # 친절체
    HARU_STYLE_ANIME = 5 # 애니체
    HARU_STYLE_RECITE = 6 # 낭독체

    HARU_STYLE_CHOICE = {
        HARU_STYLE_MONOlOGUE : "독백체",
        HARU_STYLE_DIALOGUE : "대화체",
        HARU_STYLE_NARRATE : "구연체",
        HARU_STYLE_BROADCAST : "중계체",
        HARU_STYLE_KIND : "친절체",
        HARU_STYLE_ANIME : "애니체",
        HARU_STYLE_RECITE : "낭독체"
    }

    HARU_STYLE = models.IntegerField()


    # haru gender values
    HARU_GENDER_MALE = 0
    HARU_GENDER_FEMALE = 1

    HARU_GENDER_CHOICE = {
        HARU_GENDER_MALE : "남성",
        HARU_GENDER_FEMALE : "여성"
    }

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


    def validate_old(self, old):
        return old in self.HARU_OLD_CHOICE.keys()


    def validate_style(self, style):
        return style in self.HARU_STYLE_CHOICE.keys()


    def validate_gender(self, gender):
        return gender in self.HARU_GENDER_CHOICE.keys()


    def validate_setting(self):
        return self.validate_style(self.HARU_STYLE) and self.validate_old(self.HARU_OLD) and self.validate_gender(self.HARU_GENDER)

