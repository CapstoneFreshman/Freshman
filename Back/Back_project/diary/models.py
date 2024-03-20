from django.db import models


# Create your models here.
class Diary(models.Model):
    USER_ID = models.IntegerField()  # 프라이머리키 자동생성
    DATE = models.DateTimeField(null=True,blank=True)
    EMO = models.CharField(max_length=30)

    def __str__(self):
        return self.USER_ID

class Diary_detail(models.Model):
    FEEDBACK_ID = models.IntegerField()
    TEXT = models.TextField()
    FILE_DIR = models.CharField(max_length=300)

    def __str__(self) -> str:
        return self.COMMENT_TEXT
