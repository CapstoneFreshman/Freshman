from django.core.files.uploadhandler import TemporaryFileUploadHandler

def temp_file(file):
    with TemporaryFileUploadHandler(file,None) as file_handler:
        temp_file_path = file_handler.file.temporary_file_path()
        #API에 넘겨주기
        return temp_file_path