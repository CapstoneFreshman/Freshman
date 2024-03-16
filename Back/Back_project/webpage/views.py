import json,re

from django.shortcuts import render
import bcrypt
# Create your views here.

from django.views import View
from django.http import JsonResponse
from models import USER_INFO


from django.contrib.auth import logout
from django.shortcuts import redirect

def logout_view(request):
    logout(request)
    return redirect('index')