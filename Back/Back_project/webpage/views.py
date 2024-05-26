import json,re

from django.shortcuts import render
import bcrypt
# Create your views here.

from django.views import View
from django.http import JsonResponse, HttpResponse, HttpRequest
from django.middleware import csrf
from webpage.form import CustomUserCreationForm,CustomUserChangeForm, HaruSettingChangeForm
from django.contrib.auth.decorators import login_required
from django.contrib.auth import get_user_model
from django.views.decorators.http import require_http_methods
from .models import User



from django.contrib.auth import logout, authenticate, login
from django.shortcuts import redirect, render

from haru.models import Haru_setting

def index(request):
    return render(request, 'webpage/index.html')

@require_http_methods(['POST'])
def api_login(request):
    username = request.POST.get('username')
    password = request.POST.get('password')
    
    if not username or not password:
        return JsonResponse({'error': 'Username and password are required.'}, status=400)
    
    user = authenticate(request, username=username, password=password)
    if user is not None:
        login(request, user)
        return JsonResponse({'message': 'Login successful.'})
    else:
        return JsonResponse({'error': 'Invalid credentials.'}, status=401)



def logout_view(request):
    logout(request)
    return JsonResponse({"success": True})



@require_http_methods(['POST'])
def join_view(request: HttpRequest):
    if request.method == "POST":
        form = CustomUserCreationForm(request.POST)
        res = {"success":False}
        if form.is_valid() and request.user.is_authenticated == False:
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)  # 사용자 인증
            login(request, user)  # 로그인

            haru_setting = Haru_setting.create(user.pk)
            haru_setting.save()
            res['success'] = True

        else:
            print(form.is_valid())
            print(request.user.is_authenticated)


        return JsonResponse(res)

    else:
        return JsonResponse({'csrf_token':csrf.get_token(request)})


@login_required
@require_http_methods(['GET', 'POST'])
def update(request):
    if request.method == 'POST':
        form = CustomUserChangeForm(request.POST, instance=request.user)
        if form.is_valid():
            form.save()
            return redirect('webpage:index')
    else:
        form = CustomUserChangeForm(instance=request.user)
    return render(request, 'webpage/update.html', {'form': form})


@require_http_methods(['GET', 'POST'])
def haru_setting_view(request):
    if request.method == 'POST' and request.user.is_authenticated:
        form = HaruSettingChangeForm(request.POST)
        res = {"success":False}
        if form.is_valid():
            new_setting = form.save(commit=False)

            if new_setting.validate_setting():
                new_setting.pk = request.user.pk
                new_setting.save()
                res['success'] = True
        return JsonResponse(res)
    elif request.method == 'GET' and request.user.is_authenticated:
        res = {}
        try:
            user_setting = Haru_setting.objects.get(USER_ID=request.user.pk)
            res["HARU_OLD"]  = user_setting.HARU_OLD
            res["HARU_STYLE"]  = user_setting.HARU_STYLE
            res["HARU_GENDER"]  = user_setting.HARU_GENDER

        except Haru_setting.DoesNotExist:
            res['error'] = "setting not found"

        finally:
            return JsonResponse(res)

    else:
        return JsonResponse({"error": "login first"})



@require_http_methods(['GET'])
def profile_view(request: HttpRequest):
    res = {}
    if request.user.is_authenticated:
        try:
            user = User.objects.get(id=request.user.pk)
            user_setting = Haru_setting.objects.get(USER_ID=request.user.pk)
            res['nick_name'] = user.nick_name
            res['id'] = user.username
            res['email'] = user.email
            res["HARU_OLD"]  = user_setting.HARU_OLD
            res["HARU_STYLE"]  = user_setting.HARU_STYLE
            res["HARU_GENDER"]  = user_setting.HARU_GENDER

        except Haru_setting.DoesNotExist:
            res['error'] = "user or setting not found"

    else:
        res['nick_name'] = "anonymous"
        res['id'] = "anonymous"
        res['email'] = "anonymous"
        res["HARU_OLD"]  = -1
        res["HARU_STYLE"]  = -1
        res["HARU_GENDER"]  = -1

    return JsonResponse(res)
        



@require_http_methods(['GET'])
def csrf_token_view(request: HttpRequest):
    return JsonResponse({'csrf_token':csrf.get_token(request)})
