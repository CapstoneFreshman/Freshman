from django.db import models

# Create your models here.

class USER_INFO(models.Model):
    EMAIL = models.EmailField(max_length=20)
    PASSWORD = models.CharField(max_length=30)
    NICKNAME = models.CharField(max_length=20)

    def __str__(self):
        return self.EMAIL
