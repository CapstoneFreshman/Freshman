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



from django.contrib.auth import logout, authenticate, login
from django.shortcuts import redirect, render

from haru.models import Haru_setting

def index(request):
    return render(request, 'webpage/index.html')

@login_required(login_url='webpage:login')
def logout_view(request):
    logout(request)
    return redirect('index')



@require_http_methods(['GET','POST'])
def join_view(request: HttpRequest):
    if request.method == "POST":
        form = CustomUserCreationForm(request.POST)
        if form.is_valid() and request.user.is_authenticated == False:
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)  # 사용자 인증
            login(request, user)  # 로그인

            haru_setting = Haru_setting.create(user.pk)
            haru_setting.save()

            return redirect('webpage:index')
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


@login_required
@require_http_methods(['GET', 'POST'])
def haru_setting_view(request):
    if request.method == 'POST' and request.user.authenticated:
        form = HaruSettingChangeForm(request.POST)
        res = {"success":False}
        if form.is_valid():
            new_setting = form.save(commit=False)

            if new_setting.validate_setting():
                new_setting.pk = request.user.pk
                new_setting.save()
                res['success'] = True



        return JsonResponse(res)
    return JsonResponse({'csrf_token':csrf.get_token(request)})
    


def auth_view(request: HttpRequest):
    return JsonResponse({"is_authenticated": request.user.is_authenticated})