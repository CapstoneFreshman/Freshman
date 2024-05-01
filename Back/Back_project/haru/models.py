from django.db import models


# Create your models here.
class DIARY(models.Model):
    USER_ID = models.IntegerField()
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

class DIARY_DETAIl(models.Model):
    SHORT_TEXT = models.TextField()
    FEEDBACK_TEXT = models.TextField()
    FEEDBACK_FILE_DIR = models.TextField()

    def GET_SHORT_TEXT(self):
        return self.SHORT_TEXT
    def GET_FEEDBACK_TEXT(self):
        return self.FEEDBACK_TEXT
    def GET_FEEDBACK_FILE_DIR(self):
        return self.FEEDBACK_FILE_DIR
