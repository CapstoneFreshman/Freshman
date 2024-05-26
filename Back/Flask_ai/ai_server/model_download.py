import os
import requests

# 파일 다운로드를 위한 설정
file_download_config = {
    "base_path": "models",
    "model_path": "xttsv2_2.0.2",
    "files_to_download": {
        "LICENSE.txt": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/LICENSE.txt?download=true",
        "README.md": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/README.md?download=true",
        "config.json": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/config.json?download=true",
        "model.pth": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/model.pth?download=true",
        "dvae.pth": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/dvae.pth?download=true",
        "mel_stats.pth": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/mel_stats.pth?download=true",
        "speakers_xtts.pth": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/speakers_xtts.pth?download=true",
        "vocab.json": "https://huggingface.co/coqui/XTTS-v2/resolve/v2.0.2/vocab.json?download=true"
    }
}

# 지정된 경로에 파일들을 다운로드하는 함수
def download_files(download_config):
    base_path = download_config["base_path"]
    model_path = download_config["model_path"]
    files = download_config["files_to_download"]

    # 최종 다운로드 경로 생성
    download_path = os.path.join(base_path, model_path)
    if not os.path.exists(download_path):
        os.makedirs(download_path, exist_ok=True)

    # 파일 다운로드
    for file_name, url in files.items():
        destination_path = os.path.join(download_path, file_name)
        # 파일이 이미 존재하지 않는 경우에만 다운로드
        if not os.path.exists(destination_path):
            print(f"Downloading {file_name}...")
            response = requests.get(url)
            with open(destination_path, 'wb') as f:
                f.write(response.content)

# 설정에 따라 파일들을 다운로드
download_files(file_download_config)
