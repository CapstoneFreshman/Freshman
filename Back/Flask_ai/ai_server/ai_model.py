import os
import io
import wave
import whisper
import torch
import torchaudio
import numpy as np
from enum import Enum
from openai import OpenAI
import anthropic
from dotenv import load_dotenv
from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts
import random
import soundfile as sf

# .env 파일 로드
load_dotenv()

class HaruSetting:
    HARU_OLD_YOUTH = 0
    HARU_OLD_TEENAGER = 1
    HARU_OLD_ADULT = 2
    HARU_OLD_SENIOR = 3
    HARU_OLD_CHOICE = {
        HARU_OLD_YOUTH: '유년층',
        HARU_OLD_TEENAGER: '청소년층',
        HARU_OLD_ADULT: '성인층',
        HARU_OLD_SENIOR: '노년층',
    }
    
    HARU_STYLE_MONOLOGUE = 0
    HARU_STYLE_DIALOGUE = 1
    HARU_STYLE_NARRATE = 2
    HARU_STYLE_BROADCAST = 3
    HARU_STYLE_KIND = 4
    HARU_STYLE_ANIME = 5
    HARU_STYLE_RECITE = 6
    HARU_STYLE_CHOICE = {
        HARU_STYLE_MONOLOGUE: '독백체',
        HARU_STYLE_DIALOGUE: '대화체',
        HARU_STYLE_NARRATE: '구연체',
        HARU_STYLE_BROADCAST: '중계체',
        HARU_STYLE_KIND: '친절체',
        HARU_STYLE_ANIME: '애니체',
        HARU_STYLE_RECITE: '낭독체',
    }
    
    HARU_GENDER_MALE = 0
    HARU_GENDER_FEMALE = 1
    HARU_GENDER_CHOICE = {
        HARU_GENDER_MALE: '남성',
        HARU_GENDER_FEMALE: '여성',
    }

class Intensity(Enum):
    intensity_0 = "intensity_0"
    intensity_1 = "intensity_1"
    intensity_2 = "intensity_2"
    intensity_3 = "intensity_3"

class ModelName(Enum):
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

    def set_api_key(self, api_key: str):
        self.api_key = api_key

class OpenAIApi(Inferencer):
    def __init__(self, model_name: ModelName, key: str):
        super().__init__(model_name, key)

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

        response_message = response.content if isinstance(response.content, str) else response.content[0]
        return response_message

def create_inferencer(model_name: ModelName, key: str) -> Inferencer:
    if model_name in list_GPT_models:
        return OpenAIApi(model_name, key)
    elif model_name in list_Claude_models:
        return AnthropicApi(model_name, key)

def split_text(text, max_length=95):
    words = text.split()
    segments = []
    current_segment = ""
    
    for word in words:
        if len(current_segment) + len(word) + 1 <= max_length:
            if current_segment:
                current_segment += " " + word
            else:
                current_segment = word
        else:
            segments.append(current_segment)
            current_segment = word
    
    if current_segment:
        segments.append(current_segment)
    
    return segments

def remove_silence(waveform, sample_rate, silence_threshold_db=-40, min_silence_duration_ms=100):
    silence_threshold = 10 ** (silence_threshold_db / 20)
    min_silence_samples = int(sample_rate * min_silence_duration_ms / 1000)
    
    non_silent_indices = torch.where(waveform.abs() > silence_threshold)[1]
    if len(non_silent_indices) == 0:
        return waveform
    
    start_index = non_silent_indices[0]
    end_index = non_silent_indices[-1]
    
    return waveform[:, max(0, start_index - min_silence_samples): min(waveform.size(1), end_index + min_silence_samples)]

def generate_speech(text, output_path, tokenizer_path, speaker_file_path, config_path, checkpoint_path, speaker_reference):
    print("[generate_speech] Loading model...")
    config = XttsConfig()
    config.load_json(config_path)
    model = Xtts.init_from_config(config)
    model.load_checkpoint(config, checkpoint_path=checkpoint_path, vocab_path=tokenizer_path, speaker_file_path=speaker_file_path, use_deepspeed=False)
    model.cuda()

    print("[generate_speech] Computing speaker latents...")
    gpt_cond_latent, speaker_embedding = model.get_conditioning_latents(audio_path=[speaker_reference])

    segments = split_text(text)
    temp_files = []

    for i, segment in enumerate(segments):
        print(f"[generate_speech] Inference for segment {i + 1}/{len(segments)}: {segment}")
        out = model.inference(
            segment,
            "ko",
            gpt_cond_latent,
            speaker_embedding,
            temperature=0.1
        )
        
        temp_file = f"temp_{i}.wav"
        waveform = torch.tensor(out["wav"]).unsqueeze(0)
        waveform = remove_silence(waveform, 22050)
        torchaudio.save(temp_file, waveform, 22050)
        temp_files.append(temp_file)

    print("[generate_speech] Merging audio files...")
    combined_waveform = []
    sample_rate = 22050
    for temp_file in temp_files:
        waveform, sample_rate = torchaudio.load(temp_file)
        combined_waveform.append(waveform)
        os.remove(temp_file)
    
    combined_waveform = torch.cat(combined_waveform, dim=1)
    torchaudio.save(output_path, combined_waveform, sample_rate)
    print(f"[generate_speech] Saved combined audio to {output_path}")

def get_sample_rate_wav(wav_file):
    with wave.open(wav_file, 'rb') as wf:
        sample_rate = wf.getframerate()
    return sample_rate

def stt_file_whisper(audio_file):
    print("[stt_file_whisper] Loading Whisper model...")
    model = whisper.load_model("large-v2", device="cuda")
    print("[stt_file_whisper] Transcribing audio file...")
    
    audio = np.frombuffer(audio_file.read(), np.int16).astype(np.float32)
    
    # Normalize audio to the range [-1, 1]
    audio = audio / np.max(np.abs(audio))

    result = model.transcribe(audio, language="ko")
    print("[stt_file_whisper] Transcription completed")
    print(f"[stt_file_whisper] Transcription Text : {result['text']}")
    return result["text"]

def tts_inference(text: str, gender: str, age_group: str, speech_style: str, tokenizer_path: str, speaker_file_path: str, config_path: str, checkpoint_path: str, output_wav_path: str, emotion: str, intensity: str):
    # 폴더 경로 매핑 수정
    gender_map = {"남성": "male", "여성": "female"}
    age_group_map = {"유년층": "under_20", "청소년층": "20s", "성인층": "30s", "노년층": "40s"}
    
    gender_dir = gender_map.get(gender, gender)
    age_group_dir = age_group_map.get(age_group, age_group)
    
    if emotion == "무감정":
        intensity = Intensity.intensity_0.value
    else:
        intensity = Intensity.intensity_2.value
    
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

def total(gendr, age_group, speech_style, emotion, diary):
    print("[total] Starting total process...")
    model_name_summary = ModelName.gpt_4_o.value
    model_name_feedback = ModelName.gpt_4_o.value

    hyperparameters_summary = {
        'temperature': 0.7,
        'max_tokens': 256,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0
    }

    hyperparameters_feedback = {
        'temperature': 0.7,
        'max_tokens': 256,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0
    }

    print("[total] Performing summary inference...")
    api_key_summary = os.getenv('OPENAI_API_KEY') if get_model_key(model_name_summary) == 'GPT' else os.getenv('ANTHROPIC_API_KEY')
    inferencer_summary = create_inferencer(model_name_summary, 'summary')
    inferencer_summary.set_api_key(api_key_summary)
    inferencer_summary.set_hyperparameters(hyperparameters_summary)
    summary_text = inferencer_summary.inference(diary, HaruSetting.HARU_GENDER_CHOICE[int(gendr)], HaruSetting.HARU_OLD_CHOICE[int(age_group)], HaruSetting.HARU_STYLE_CHOICE[int(speech_style)], emotion, Intensity.intensity_0.value)

    print("[total] Performing feedback inference...")
    api_key_feedback = os.getenv('OPENAI_API_KEY') if get_model_key(model_name_feedback) == 'GPT' else os.getenv('ANTHROPIC_API_KEY')
    inferencer_feedback = create_inferencer(model_name_feedback, 'feedback')
    inferencer_feedback.set_api_key(api_key_feedback)
    inferencer_feedback.set_hyperparameters(hyperparameters_feedback)
    feedback_text = inferencer_feedback.inference(diary, HaruSetting.HARU_GENDER_CHOICE[int(gendr)], HaruSetting.HARU_OLD_CHOICE[int(age_group)], HaruSetting.HARU_STYLE_CHOICE[int(speech_style)], emotion, Intensity.intensity_0.value)

    print("[total] Generating TTS from feedback text...")
    output_wav_path = "output.wav"
    tokenizer_path = "./models/xttsv2_2.0.2/vocab.json"
    speaker_file_path = "./models/xttsv2_2.0.2/speakers_xtts.pth"
    config_path = "./models/xttsv2_2.0.2/config.json"
    checkpoint_path = "./models/xttsv2_2.0.2/model.pth"

    tts_inference(feedback_text, HaruSetting.HARU_GENDER_CHOICE[int(gendr)], HaruSetting.HARU_OLD_CHOICE[int(age_group)], HaruSetting.HARU_STYLE_CHOICE[int(speech_style)], tokenizer_path, speaker_file_path, config_path, checkpoint_path, output_wav_path, emotion, Intensity.intensity_2.value)

    with open(output_wav_path, "rb") as audio_file:
        audio_content = audio_file.read()

    result = {
        "file": {
            "feedback_file": audio_content
        },
        "feedback_text": feedback_text,
        "short_text": summary_text  # 요약된 다이어리 내용을 포함
    }
    print("[total] Process completed")
    print(f"[total] Feedback Text: {feedback_text}")
    print(f"[total] Summary Text: {summary_text}")
    return result
