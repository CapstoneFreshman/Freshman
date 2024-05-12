from django.shortcuts import render, redirect
from haru.models import Diary,Diary_detail

from haru.form import Get_diary
from haru.form import Get_detail

def save_diary(request):
    if request.method == 'POST':
        form = Get_diary(request.POST)
        if form.is_valid():
            form.save()
            return redirect('success')  # 성공 페이지로 리디렉션합니다.
    else:
        form = Get_diary()
    return render(request, 'haru/form.html', {'form': form})

def success(request):
    return render(request, 'haru/success.html')
