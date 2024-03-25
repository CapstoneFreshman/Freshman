from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth import get_user_model


class User(AbstractUser):
    nick_name = models.CharField(max_length=255, blank=True, null=True)




#
# class USER_INFO(models.Model):
#     AUTH = models.ForeignKey(User, on_delete=models.CASCADE)
#     USERNAME = models.CharField(max_length=20)
#     PASSWORD = models.CharField(max_length=30)
#     EMAIL = models.EmailField(max_length=20)
#
#     def __str__(self):
#         return self.USERNAME
