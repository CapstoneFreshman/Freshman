import os

import boto3
from django.conf import settings
from django.http import JsonResponse

def upload_wav_to_s3(request,content,path_tag):
    if request.method == 'POST' and request.FILES['wav_file']:
        wav_file = request.FILES['wav_file']

        # S3에 연결
        s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_S3_REGION_NAME
        )

        # S3 버킷 이름
        bucket_name = settings.AWS_STORAGE_BUCKET_NAME
        file_path = os.path.join(content,path_tag)
        # S3에 WAV 파일 업로드
        s3_client.upload_fileobj(wav_file, bucket_name, file_path)


        # 업로드된 파일의 URL 생성
        s3_file_url = f"https://{bucket_name}.s3.amazonaws.com/{file_path}"

        return JsonResponse({'url': s3_file_url})
    else:
        return JsonResponse({'error': 'No WAV file uploaded'}, status=400)