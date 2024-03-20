import json,re

from django.shortcuts import render
import bcrypt
# Create your views here.

from django.views import View
from django.http import JsonResponse
from webpage.form import CustomUserCreationForm,CustomUserChangeForm
from django.contrib.auth.decorators import login_required
from django.contrib.auth import get_user_model
from django.views.decorators.http import require_http_methods


from django.contrib.auth import logout, authenticate, login
from django.shortcuts import redirect, render


def index(request):
    return render(request, 'webpage/index.html')

@login_required(login_url='webpage:login')
def logout_view(request):
    logout(request)
    return redirect('index')

@require_http_methods(['GET','POST'])
def join_view(request):
    if request.user.is_authenticated:
        return redirect('webpage:index')
    if request.method == "POST":
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)  # 사용자 인증
            login(request, user)  # 로그인
            return redirect('webpage:index')
    else:
        form = CustomUserCreationForm()
    return render(request, 'webpage/join.html', {'form': form})

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