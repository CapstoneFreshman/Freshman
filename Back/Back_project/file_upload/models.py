from django.db import models

# Create your models here.
class voice_upload(models.Model):
    TITLE = models.TextField(max_length=30,null=True)
    VOICE_FILE = models.FileField(upload_to='')
    PARAM = models.IntegerField();
    def __str__(self):
        return self.TITLE