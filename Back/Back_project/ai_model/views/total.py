import argparse
import os
from enum import Enum
from openai import OpenAI
import anthropic
from dotenv import load_dotenv
import random
import wave
import whisper
from xtts import generate_speech
import re

# .env 파일 로드
load_dotenv()

# Enums
class BaseEnum(Enum):
    @classmethod
    def get_values(cls):
        return [e.value for e in cls]

class Gender(BaseEnum):
    남성 = "남성"
    여성 = "여성"

class AgeGroup(BaseEnum):
    유년층 = "유년층"
    청소년층 = "청소년층"
    성인층 = "성인층"
    노년층 = "노년층"

class SpeechStyle(BaseEnum):
    구연체 = "구연체"
    낭독체 = "낭독체"
    대화체 = "대화체"
    독백체 = "독백체"
    애니체 = "애니체"
    중계체 = "중계체"
    친절체 = "친절체"

class Emotion(BaseEnum):
    기쁨 = "기쁨"
    무감정 = "무감정"
    슬픔 = "슬픔"
    분노 = "분노"

class Intensity(BaseEnum):
    intensity_0 = "intensity_0"
    intensity_1 = "intensity_1"
    intensity_2 = "intensity_2"
    intensity_3 = "intensity_3"

class ModelName(BaseEnum):
    gpt_4_o = "gpt-4o"
    Claude_3_opus = "claude-3-opus-20240229"
    Claude_3_sonnet = "claude-3-sonnet-20240229"

def get_hyperparameters(model_value: str) -> list:
    if model_value in list_GPT_models:
        return [
            'temperature',
            'max_tokens',
            'top_p',
            'frequency_penalty',
            'presence_penalty'
        ]
    elif model_value in list_Claude_models:
        return [
            'temperature',
            'max_tokens',
            'top_p',
        ]
    else:
        raise ValueError(f"Invalid model name: {model_value}")

def get_model_key(model_value: str) -> str:
    if model_value in list_GPT_models:
        return "GPT"
    elif model_value in list_Claude_models:
        return "Claude"
    else:
        raise ValueError(f"Invalid model name: {model_value}")

list_Claude_models = [ModelName.Claude_3_opus.value, ModelName.Claude_3_sonnet.value]
list_GPT_models = [ModelName.gpt_4_o.value]

# Inferencer
def validate_inferencer(func):
    def wrapper(self, *args, **kwargs):
        assert self.target_hyperparameters is not None, "hyperparameters is not set"
        assert type(self.target_hyperparameters) == dict, "hyperparameters is not a dictionary"
        return func(self, *args, **kwargs)
    return wrapper

def combine_dairy_with_prompt(prompt: str, diary: str, gender: str, age: str, speech_style: str, emotion: str, intensity: str) -> str:
    prompt_with_diary = prompt.format(diary=diary, gender=gender, age_group=age, speech_style=speech_style, emotion=emotion, intensity=intensity)
    return prompt_with_diary

class Inferencer:
    def __init__(self, model_name: str, key: str):
        self.model_name = get_model_key(model_name)
        self.model_id = model_name
        self.key = key
        self.system_prompt = self.load_system_prompt("system_prompt", self.key)
        self.target_hyperparameters = None

    def load_system_prompt(self, path: str, key: str) -> str:
        extension = "md" if self.model_name == "GPT" else "xml"
        file_path = f"{path}/{self.model_name}_{key}.{extension}"
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()

    def inference(self, diary: str, gender: str, age_group: str, speech_style: str, emotion: str, intensity: str) -> str:
        pass

    def set_hyperparameters(self, hyperparameters: dict):
        self.target_hyperparameters = hyperparameters
        print(self.target_hyperparameters)

    def set_api_key(self, api_key: str):
        self.api_key = api_key

class OpenAIApi(Inferencer):
    def __init__(self, model_name: ModelName, key: str):
        super().__init__(model_name, key)

    @validate_inferencer
    def inference(self, diary: str, gender: str, age_group: str, speech_style: str, emotion: str, intensity: str) -> str:
        app = OpenAI(api_key=self.api_key)
        combined = combine_dairy_with_prompt(
            self.system_prompt,
            diary,
            gender,
            age_group,
            speech_style,
            emotion,
            intensity
        )
        response = app.chat.completions.create(
            model=self.model_id,
            messages=[
                {"role": "system", "content": combined},
            ],
            **self.target_hyperparameters
        )
        return response.choices[0].message.content

class AnthropicApi(Inferencer):
    def __init__(self, model_name: ModelName, key: str):
        super().__init__(model_name, key)

    @validate_inferencer
    def inference(self, diary: str, gender: str, age_group: str, speech_style: str, emotion: str, intensity: str) -> str:
        app = anthropic.Client(api_key=self.api_key)

        prompt = combine_dairy_with_prompt(
            self.system_prompt,
            diary,
            gender,
            age_group,
            speech_style,
            emotion,
            intensity
        )

        response = app.messages.create(
            model=self.model_id,
            messages=[
                {"role": "user", "content": prompt}
            ],
            max_tokens=self.target_hyperparameters.get('max_tokens', 256),
            temperature=self.target_hyperparameters.get('temperature', 0.7),
            top_p=self.target_hyperparameters.get('top_p', 1.0)
        )

        if isinstance(response.content, list):
            response_message = response.content[0]
        else:
            response_message = response.content

        if hasattr(response_message, 'text'):
            response_message = response_message.text

        return response_message

def create_inferencer(model_name: ModelName, key: str) -> Inferencer:
    if model_name in list_GPT_models:
        print(f"{model_name} is GPT model")
        return OpenAIApi(model_name, key)
    elif model_name in list_Claude_models:
        return AnthropicApi(model_name, key)

def tts_inference(text: str, gender: str, age_group: str, speech_style: str, tokenizer_path: str, speaker_file_path: str, config_path: str, checkpoint_path: str, output_wav_path: str, emotion: str, intensity: str):
    # 폴더 경로 매핑 수정
    gender_map = {"남성": "male", "여성": "female"}
    age_group_map = {"유년층": "kids", "청소년층": "teens", "성인층": "20s", "노년층": "seniors"}
    
    gender_dir = gender_map.get(gender, gender)
    age_group_dir = age_group_map.get(age_group, age_group)
    
    dir_path = os.path.join("tts_references", gender_dir, age_group_dir, speech_style, emotion, intensity)
    
    if not os.path.exists(dir_path):
        raise FileNotFoundError(f"Directory for TTS reference not found: {dir_path}")
    
    wav_files = [f for f in os.listdir(dir_path) if f.endswith('.wav')]
    
    if not wav_files:
        raise FileNotFoundError(f"No WAV files found in directory: {dir_path}")
    
    reference_file = random.choice(wav_files)
    reference_file_path = os.path.join(dir_path, reference_file)

    generate_speech(text, output_wav_path, tokenizer_path, speaker_file_path, config_path, checkpoint_path, reference_file_path)
    print(f"TTS output generated: {output_wav_path}")

def get_sample_rate_wav(wav_file):
    with wave.open(wav_file, 'rb') as wf:
        sample_rate = wf.getframerate()
    return sample_rate

def transcribe_audio_with_whisper(audio_file):
    model = whisper.load_model("large-v2", device="cuda")
    sample_rate_hertz = get_sample_rate_wav(audio_file)
    result = model.transcribe(audio_file, language="ko")
    return result["text"]

def main(model_name_summary, model_name_feedback, gender, age_group, speech_style, diary, hyperparameters_summary, hyperparameters_feedback, tokenizer_path, speaker_file_path, config_path, checkpoint_path, output_wav_path, input_audio_path=None, emotion="무감정", intensity="intensity_0"):
    if input_audio_path:
        diary = transcribe_audio_with_whisper(input_audio_path)
        print(f"Transcribed Text: {diary}")

    print(f"Emotion: {emotion}, Intensity: {intensity}")

    # 요약을 위한 인퍼런서 설정
    api_key_summary = os.getenv('OPENAI_API_KEY') if get_model_key(model_name_summary) == 'GPT' else os.getenv('ANTHROPIC_API_KEY')
    if not api_key_summary:
        raise ValueError("API key for summary is missing in the environment variables")

    inferencer_summary = create_inferencer(model_name_summary, 'summary')
    inferencer_summary.set_api_key(api_key_summary)
    inferencer_summary.set_hyperparameters(hyperparameters_summary)
    summary_text = inferencer_summary.inference(diary, gender, age_group, speech_style, emotion, intensity)
    print("Summary Text:", summary_text)
    
    # 피드백을 위한 인퍼런서 설정
    api_key_feedback = os.getenv('OPENAI_API_KEY') if get_model_key(model_name_feedback) == 'GPT' else os.getenv('ANTHROPIC_API_KEY')
    if not api_key_feedback:
        raise ValueError("API key for feedback is missing in the environment variables")

    inferencer_feedback = create_inferencer(model_name_feedback, 'feedback')
    inferencer_feedback.set_api_key(api_key_feedback)
    inferencer_feedback.set_hyperparameters(hyperparameters_feedback)
    feedback_text = inferencer_feedback.inference(diary, gender, age_group, speech_style, emotion, intensity)
    print("Feedback Text:", feedback_text)

    # 피드백 텍스트를 음성으로 변환
    tts_inference(feedback_text, gender, age_group, speech_style, tokenizer_path, speaker_file_path, config_path, checkpoint_path, output_wav_path, emotion, intensity)
    print("Feedback TTS generated:", output_wav_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process diary transformation and TTS output.')
    parser.add_argument('--model_name_summary', type=str, choices=ModelName.get_values(), default=ModelName.gpt_4_o.value, help='Model name for summary')
    parser.add_argument('--model_name_feedback', type=str, choices=ModelName.get_values(), default=ModelName.gpt_4_o.value, help='Model name for feedback')
    parser.add_argument('--gender', type=str, choices=Gender.get_values(), default=Gender.남성.value, help='Gender of the speaker')
    parser.add_argument('--age_group', type=str, choices=AgeGroup.get_values(), default=AgeGroup.성인층.value, help='Age group of the speaker')
    parser.add_argument('--speech_style', type=str, choices=SpeechStyle.get_values(), default=SpeechStyle.구연체.value, help='Speech style')
    parser.add_argument('--emotion', type=str, choices=Emotion.get_values(), default=Emotion.무감정.value, help='Emotion')
    parser.add_argument('--intensity', type=str, choices=Intensity.get_values(), default=Intensity.intensity_0.value, help='Emotion intensity')
    parser.add_argument('--diary', type=str, help='Diary text')
    parser.add_argument('--temperature_summary', type=float, default=0.7, help='Temperature setting for the summary model')
    parser.add_argument('--max_tokens_summary', type=int, default=256, help='Max tokens setting for the summary model')
    parser.add_argument('--top_p_summary', type=float, default=1.0, help='Top P setting for the summary model')
    parser.add_argument('--temperature_feedback', type=float, default=0.7, help='Temperature setting for the feedback model')
    parser.add_argument('--max_tokens_feedback', type=int, default=256, help='Max tokens setting for the feedback model')
    parser.add_argument('--top_p_feedback', type=float, default=1.0, help='Top P setting for the feedback model')
    parser.add_argument('--frequency_penalty', type=float, default=0.0, help='Frequency penalty setting for the model')
    parser.add_argument('--presence_penalty', type=float, default=0.0, help='Presence penalty setting for the model')
    parser.add_argument('--tokenizer_path', type=str, default="./models/xttsv2_2.0.2/vocab.json", help='Path to tokenizer')
    parser.add_argument('--speaker_file_path', type=str, default="./models/xttsv2_2.0.2/speakers_xtts.pth", help='Path to speaker file')
    parser.add_argument('--config_path', type=str, default="./models/xttsv2_2.0.2/config.json", help='Path to config file')
    parser.add_argument('--checkpoint_path', type=str, default="./models/xttsv2_2.0.2/model.pth", help='Path to model checkpoint')
    parser.add_argument('--output_wav_path', type=str, default="output.wav", help='Path to output wav file')
    parser.add_argument('--input_audio_path', type=str, help='Path to input audio file')

    args = parser.parse_args()

    hyperparameters_summary = {
        'temperature': args.temperature_summary,
        'max_tokens': args.max_tokens_summary,
        'top_p': args.top_p_summary,
        'frequency_penalty': args.frequency_penalty,
        'presence_penalty': args.presence_penalty
    }

    hyperparameters_feedback = {
        'temperature': args.temperature_feedback,
        'max_tokens': args.max_tokens_feedback,
        'top_p': args.top_p_feedback,
        'frequency_penalty': args.frequency_penalty,
        'presence_penalty': args.presence_penalty
    }

    # 무감정일 경우 intensity를 intensity_0으로 설정
    if args.emotion == Emotion.무감정.value:
        args.intensity = Intensity.intensity_0.value

    main(args.model_name_summary, args.model_name_feedback, args.gender, args.age_group, args.speech_style, args.diary, hyperparameters_summary, hyperparameters_feedback, args.tokenizer_path, args.speaker_file_path, args.config_path, args.checkpoint_path, args.output_wav_path, args.input_audio_path, args.emotion, args.intensity)
