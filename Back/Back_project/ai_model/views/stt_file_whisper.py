import io
import wave
import whisper

def get_sample_rate_wav(wav_file):
    with wave.open(wav_file, 'rb') as wf:
        sample_rate = wf.getframerate()
    return sample_rate

def transcribe_audio_with_whisper(audio_file, output_text_file):
    # Whisper 모델 로드
    model = whisper.load_model("large-v3", device="cuda")

    # 오디오 파일에서 샘플 속도 가져오기 (Whisper에서는 필요하지 않을 수 있지만, 다른 용도로 사용될 수 있음)
    sample_rate_hertz = get_sample_rate_wav(audio_file)

    # Whisper를 사용하여 오디오 파일을 텍스트로 변환
    result = model.transcribe(audio_file, language="ko")

    # 텍스트 파일로 결과 저장
    with open(output_text_file, "w") as text_file:
        text_file.write("Transcript: {}\n".format(result["text"]))

if __name__ == "__main__":
    audio_file = "0.wav"  # 변환할 오디오 파일 경로
    output_text_file = "transcribed_text.txt"  # 결과를 저장할 텍스트 파일 경로

    transcribe_audio_with_whisper(audio_file, output_text_file)
