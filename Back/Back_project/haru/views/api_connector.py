import os
import tempfile
import shutil
import requests

# Whisper API 및 GPT API의 엔드포인트와 키
WHISPER_API_ENDPOINT = "https://api.whisper.ai/api/v1/transcribe"
GPT_API_ENDPOINT = "https://api.openai.com/v1/engines/davinci/completions"
GPT_API_KEY = "YOUR_OPENAI_API_KEY"

def transcribe_audio(file_path):
    # Whisper API를 사용하여 음성을 텍스트로 변환
    headers = {"Authorization": "Bearer YOUR_WHISPER_API_KEY"}
    files = {"file": open(file_path, "rb")}
    response = requests.post(WHISPER_API_ENDPOINT, headers=headers, files=files)
    transcribed_text = response.json()["transcript"]
    return transcribed_text

def summarize_text(text):
    # GPT API를 사용하여 텍스트 요약 생성
    prompt = "요약해주세요: " + text
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {GPT_API_KEY}"
    }
    data = {
        "prompt": prompt,
        "max_tokens": 50
    }
    response = requests.post(GPT_API_ENDPOINT, json=data, headers=headers)
    summary = response.json()["choices"][0]["text"].strip()
    return summary
def feedback_text(text,emo):
    # GPT API를 사용하여 텍스트 공감
    if emo == "기쁨":
        emo_text = "기쁨을 축하하는"
    elif emo == "슬픔":
        emo_text = "슬픔을 위로하는"
    elif emo == "분노":
        emo_text = "분노에 공감하는"
    elif emo == "무감정":
        emo_text = "담담한"
    else:
        raise Exception("감정이 선택되지 않았습니다.")
    prompt = "" + emo_text + "" + text
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {GPT_API_KEY}"
    }
    data = {
        "prompt": prompt,
        "max_tokens": 50
    }
    response = requests.post(GPT_API_ENDPOINT, json=data, headers=headers)
    feedback = response.json()["choices"][0]["text"].strip()
    return feedback

def main():
    # 음성 파일 다운로드 및 임시 폴더에 저장
    audio_url = "URL_OF_YOUR_AUDIO_FILE"
    temp_dir = tempfile.mkdtemp()
    audio_file_path = os.path.join(temp_dir, "audio_file.wav")
    response = requests.get(audio_url)
    with open(audio_file_path, "wb") as f:
        f.write(response.content)

    # 음성을 텍스트로 변환
    transcribed_text = transcribe_audio(audio_file_path)

    # 텍스트 요약 생성
    summary = summarize_text(transcribed_text)

    print("음성을 텍스트로 변환한 내용:")
    print(transcribed_text)
    print("\n5줄 요약:")
    print(summary)

    # 임시 폴더 정리
    shutil.rmtree(temp_dir)

if __name__ == "__main__":
    main()
