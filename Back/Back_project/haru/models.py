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
