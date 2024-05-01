from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    nick_name = models.CharField(max_length=255, blank=True, null=True)


class HARU_SETTING(models):
    user_id = models.IntegerField()
    haru_old = models.IntegerField()
    haru_style = models.IntegerField()
    haru_gender = models.IntegerField()

    def get_setting(self):
        return f'{self.haru_old}, {self.haru_style}, {self.haru_gender}'



