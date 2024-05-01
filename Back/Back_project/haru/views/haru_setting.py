from django.shortcuts import render, redirect
from haru.models import Diary,Diary_detail

from webpage.form import HaruSetting


def haru_setting(request):
    if request.method == 'POST':
        form = HaruSetting(request.POST)
        if form.is_valid():
            form.save()
            return redirect('success')
    else:
        form = HaruSetting()
    return render(request, 'haru/haru_setting.html', {'form': form})

def success(request):
    return render(request, 'haru/set_success.html')
