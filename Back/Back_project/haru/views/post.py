from django.shortcuts import render
from django.contrib import messages
from haru.models import Diary
# Create your views here.
def record(request):
    if request.user.is_authenticated:
        user_id = request.user.id
    else:
        messages.warning(request,"로그인이 필요한 서비스입니다.")
        return render('webpage:index')
    user_diary_set = Diary.objects.filter(id=user_id)











