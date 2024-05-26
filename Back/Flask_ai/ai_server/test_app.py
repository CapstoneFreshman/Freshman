import requests

# 서버 주소
url = 'http://127.0.0.1:5000/upload'

# 테스트용 파일 경로와 데이터
audio_file_path = '0.wav'  # 실제 오디오 파일 경로로 수정
data = {
    'haru_gender': '0',  # 남성
    'haru_age': '2',     # 성인층
    'haru_style': '2',   # 구연체
    'emo': '기쁨'
}

# 파일 업로드
with open(audio_file_path, 'rb') as f:
    files = {'ori_file': f}
    response = requests.post(url, data=data, files=files)

# 응답 출력
print('Status Code:', response.status_code)
print('Response JSON:', response.json())
