import requests
import time

claims_url = "http://localhost:8000/patients/claims"
patient_registration_url = "http://localhost:8000/patients/membership"
file_types = ["claims", "patient_registration"]
files_set_1 = [
    'Patient-membership-clientA-202307.xlsx',
    'Patient-membership-clientB-202307.xlsx',

    'Patient-claim-clientA-202307.xlsx',
    'Patient-claim-clientB-202307.xlsx'
]
files_set_2 = [
    'Patient-membership-clientA-202308.xlsx',
    'Patient-claim-clientA-202308.xlsx'
]

def handle_upload(files, set_num):
    for file in files:
        if 'claim' in file:
            url = claims_url
        else:
            url = patient_registration_url
        req=[
            ('file',
             (file,open(f'./test_files/{set_num}/{file}','rb'),
                     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))
        ]
        response = requests.request("POST", url, files=req)
        time.sleep(2)
        print(f"Uploaded: {file} Status code: {response.status_code}")

handle_upload(files_set_1, "set1")
handle_upload(files_set_2, "set2")