from flask import Flask, request, jsonify
from ai_model import total, stt_file_whisper
import io

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'ori_file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    input_file = request.files['ori_file']
    json_data = request.form.to_dict()
    if input_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # STT 텍스트 파일 가져오기
    ori_text = stt_file_whisper(input_file)

    # total에 필요한 정보 넣어서 result JSON + 파일 뭉치 가져오기
    result = total(
        gendr=json_data['haru_gender'],
        age_group=json_data['haru_age'],
        speech_style=json_data['haru_style'],
        emotion=json_data['emo'],
        diary=ori_text
    )

    output_file = result['file']['feedback_file']
    feedback_file = io.BytesIO(output_file)
    feedback_file.seek(0)
    
    feedback_text = result['feedback_text']
    short_text = result['short_text']
    
    ai_data = {
        'feedback_text': feedback_text,
        'short_text': short_text
    }
    
    # 리스폰스를 생성하여 반환
    return jsonify(ai_data), 200

if __name__ == '__main__':
    app.run(debug=True)
