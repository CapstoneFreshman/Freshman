import os
import torch
import torchaudio
from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts

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
    """
    Remove silence from the waveform.
    """
    silence_threshold = 10 ** (silence_threshold_db / 20)
    min_silence_samples = int(sample_rate * min_silence_duration_ms / 1000)
    
    non_silent_indices = torch.where(waveform.abs() > silence_threshold)[1]
    if len(non_silent_indices) == 0:
        return waveform
    
    start_index = non_silent_indices[0]
    end_index = non_silent_indices[-1]
    
    return waveform[:, max(0, start_index - min_silence_samples): min(waveform.size(1), end_index + min_silence_samples)]

def generate_speech(text, output_path, tokenizer_path, speaker_file_path, config_path, checkpoint_path, speaker_reference):
    print("Loading model...")
    config = XttsConfig()
    config.load_json(config_path)
    model = Xtts.init_from_config(config)
    model.load_checkpoint(config, checkpoint_path=checkpoint_path, vocab_path=tokenizer_path, speaker_file_path=speaker_file_path, use_deepspeed=False)
    model.cuda()

    print("Computing speaker latents...")
    gpt_cond_latent, speaker_embedding = model.get_conditioning_latents(audio_path=[speaker_reference])

    segments = split_text(text)
    temp_files = []

    for i, segment in enumerate(segments):
        print(f"Inference for segment {i + 1}/{len(segments)}: {segment}")
        out = model.inference(
            segment,
            "ko",
            gpt_cond_latent,
            speaker_embedding,
            temperature=0.1,  # 필요한 경우 온도를 조정합니다
        )
        
        temp_file = f"temp_{i}.wav"
        waveform = torch.tensor(out["wav"]).unsqueeze(0)
        waveform = remove_silence(waveform, 22050)  # silence_threshold_db와 min_silence_duration_ms를 필요한 경우 조정합니다
        torchaudio.save(temp_file, waveform, 22050)  # 필요한 경우 샘플 레이트를 조정합니다
        temp_files.append(temp_file)

    print("Merging audio files...")
    combined_waveform = []
    sample_rate = 22050  # 샘플 레이트를 한 번만 정의하고 이후로 사용
    for temp_file in temp_files:
        waveform, sample_rate = torchaudio.load(temp_file)
        combined_waveform.append(waveform)
        os.remove(temp_file)
    
    combined_waveform = torch.cat(combined_waveform, dim=1)
    torchaudio.save(output_path, combined_waveform, sample_rate)
    print(f"Saved combined audio to {output_path}")

# Example usage:
# generate_speech("텍스트", "output.wav", "path/to/tokenizer.json", "path/to/speaker.pth", "path/to/config.json", "path/to/checkpoint.pth", "path/to/speaker_reference.wav")
