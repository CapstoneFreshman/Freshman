# app.py
from flask import Flask, request, jsonify
from .ai_server.ai_model import total,stt_file_whisper
import io
from werkzeug.exceptions import HTTPException,BadRequest

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return BadRequest(description ="There is no file exists")
    input_file = request.files['ori_file']
    json_data = request.form.dict()
    if input_file.filename == '':
        return BadRequest(description ="No file name")
    ori_text = stt_file_whisper(input_file) #STT 텍스트 파일 가져오기
    result = total(
        gendr = json_data['haru_gender'],
        age_group = json_data['haru_age'],
        speech_style = json_data['haru_style'],
        emotion = json_data['emo'],
        diary = ori_text
    )#total에 필요한 정보 넣어서 result JSON + 파일 뭉치 가져오기
    output_file = result.file['feedback_file']
    output_data = result.form.to_dict()
    feedback_text = output_data.get('feedback_text')
    short_text = output_data.get('short_text')
    response_data = {'feedback_text': feedback_text,
                     'short_text' : short_text,
               }
    response = requests.post(django_server_url,files = output_file,data = response_data)
    #리스폰스를 만들쟈
    if response.status_code != 200:
        return BadRequest(description = "Fail to send to Django")
    return jsonify(response.json()),response.status_code

if __name__ == '__main__':
    app.run(debug=True)