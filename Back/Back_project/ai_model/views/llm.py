import argparse
import os
from enum import Enum
from openai import OpenAI
import anthropic
from dotenv import load_dotenv

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

def combine_dairy_with_prompt(prompt: str, diary: str, gender: str, age: str, speech_style: str) -> str:
    password = "{diary}"
    gender_password = "{gender}"
    age_password = "{age_group}"
    speech_style_password = "{speech_style}"
    return prompt.replace(password, diary).replace(gender_password, gender).replace(age_password, age).replace(speech_style_password, speech_style)

class Inferencer:
    def __init__(self, model_name: str, key: str):
        self.model_name = get_model_key(model_name)
        self.model_id = model_name
        self.key = key
        self.system_prompt = self.load_system_prompt("system_prompt", self.model_name)
        self.target_hyperparameters = None

    def load_system_prompt(self, path: str, model_name: str) -> str:
        extension = "md" if self.model_name == "GPT" else "xml"
        file_path = f"{path}/{model_name}_{self.key}.{extension}"
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()

    def inference(self, prompt: str, gender: str, age_group: str, speech_style: str) -> str:
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
    def inference(self, prompt: str, gender: str, age_group: str, speech_style: str) -> str:
        app = OpenAI(api_key=self.api_key)
        combined = combine_dairy_with_prompt(
            self.system_prompt,
            prompt,
            gender,
            age_group,
            speech_style
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
    def inference(self, prompt: str, gender: str, age_group: str, speech_style: str) -> str:
        app = anthropic.Anthropic(api_key=self.api_key)
        combined = combine_dairy_with_prompt(
            self.system_prompt,
            prompt,
            gender,
            age_group,
            speech_style
        )
        response = app.messages.create(
            model=self.model_id,
            system=combined,
            messages=[],
            **self.target_hyperparameters
        )
        return response.content[0].text

def create_inferencer(model_name: ModelName, key: str) -> Inferencer:
    if model_name in list_GPT_models:
        print(f"{model_name} is GPT model")
        return OpenAIApi(model_name, key)
    elif model_name in list_Claude_models:
        return AnthropicApi(model_name, key)

def main(model_name, gender, age_group, speech_style, diary, hyperparameters):
    api_key = os.getenv('OPENAI_API_KEY') if get_model_key(model_name) == 'GPT' else os.getenv('ANTHROPIC_API_KEY')
    if not api_key:
        raise ValueError("API key is missing in the environment variables")

    inferencer = create_inferencer(model_name, 'transform')
    inferencer.set_api_key(api_key)
    inferencer.set_hyperparameters(hyperparameters)
    result = inferencer.inference(diary, gender, age_group, speech_style)
    print("변환된 텍스트:", result)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process diary transformation.')
    parser.add_argument('--model_name', type=str, choices=ModelName.get_values(), required=True, help='Model name')
    parser.add_argument('--gender', type=str, choices=Gender.get_values(), required=True, help='Gender of the speaker')
    parser.add_argument('--age_group', type=str, choices=AgeGroup.get_values(), required=True, help='Age group of the speaker')
    parser.add_argument('--speech_style', type=str, choices=SpeechStyle.get_values(), required=True, help='Speech style')
    parser.add_argument('--diary', type=str, required=True, help='Diary text')
    parser.add_argument('--temperature', type=float, default=0.7, help='Temperature setting for the model')
    parser.add_argument('--max_tokens', type=int, default=256, help='Max tokens setting for the model')
    parser.add_argument('--top_p', type=float, default=1.0, help='Top P setting for the model')
    parser.add_argument('--frequency_penalty', type=float, default=0.0, help='Frequency penalty setting for the model')
    parser.add_argument('--presence_penalty', type=float, default=0.0, help='Presence penalty setting for the model')

    args = parser.parse_args()

    hyperparameters = {
        'temperature': args.temperature,
        'max_tokens': args.max_tokens,
        'top_p': args.top_p,
        'frequency_penalty': args.frequency_penalty,
        'presence_penalty': args.presence_penalty
    }

    main(args.model_name, args.gender, args.age_group, args.speech_style, args.diary, hyperparameters)
