from xtts import generate_speech

# 필요한 경로 설정
TOKENIZER_PATH = "./models/xttsv2_2.0.2/vocab.json"
SPEAKER_FILE_PATH = "./models/xttsv2_2.0.2/speakers_xtts.pth"
CONFIG_PATH = "./models/xttsv2_2.0.2/config.json"
XTTS_CHECKPOINT = "./models/xttsv2_2.0.2/model.pth"
SPEAKER_REFERENCE = "0.wav"
OUTPUT_WAV_PATH = "output.wav"

# 텍스트 설정
text = "안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라안녕하세요 저는 영웅입니다. 임영웅 방탄소년단 비켜라"

# generate_speech 함수 호출
generate_speech(text, OUTPUT_WAV_PATH, TOKENIZER_PATH, SPEAKER_FILE_PATH, CONFIG_PATH, XTTS_CHECKPOINT, SPEAKER_REFERENCE)
