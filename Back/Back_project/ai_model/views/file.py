import os
import shutil
import json

# Base directory where JSON and WAV files are located
base_dir = r'C:\Users\jun-xn\Desktop\diary\133.감성 및 발화 스타일 동시 고려 음성합성 데이터\01-1.정식개방데이터\Validation'
all_wav_dir = os.path.join(base_dir, '01.원천데이터')
json_dir = os.path.join(base_dir, '02.라벨링데이터')

# Directory for tts references
tts_references_dir = os.path.join(base_dir, 'tts_references')
if not os.path.exists(tts_references_dir):
    os.makedirs(tts_references_dir)

# Function to get age group based on age
def get_age_group(age):
    if age < 20:
        return 'under_20'
    elif 20 <= age < 30:
        return '20s'
    elif 30 <= age < 40:
        return '30s'
    elif 40 <= age < 50:
        return '40s'
    elif 50 <= age < 60:
        return '50s'
    else:
        return '60_and_above'

# Collect all WAV files in a dictionary with filenames as keys for quick access
wav_files = {}
for root, dirs, files in os.walk(all_wav_dir):
    for file in files:
        if file.endswith('.wav'):
            wav_files[file] = os.path.join(root, file)

# Walk through the directory and process each JSON file
for root, dirs, files in os.walk(json_dir):
    for file in files:
        if file.endswith('.json'):
            json_file_path = os.path.join(root, file)
            with open(json_file_path, 'r', encoding='utf-8') as f:
                data_list = json.load(f)
            
            # Process each item in the data list
            for data in data_list:
                reciter_info = data['reciter']
                gender = reciter_info['gender'].lower()
                age_group = get_age_group(reciter_info['age'])
                sentences = data['sentences']

                for sentence in sentences:
                    style = sentence['style']['style']
                    emotion = sentence['style']['emotion']
                    intensity = sentence['style']['intensity']
                    filename = sentence['voice_piece']['filename']
                    
                    # Create the directory path with emotion and intensity
                    dir_path = os.path.join(tts_references_dir, gender, age_group, style, emotion, f'intensity_{intensity}')
                    if not os.path.exists(dir_path):
                        os.makedirs(dir_path)
                    
                    # Copy the file to the corresponding directory if it exists
                    if filename in wav_files:
                        dest_file_path = os.path.join(dir_path, filename)
                        shutil.copy(wav_files[filename], dest_file_path)
                        print(f"Copied: {filename} to {dest_file_path}")
                    else:
                        print(f"File {filename} not found in WAV files!")

print("Files organized successfully!")
