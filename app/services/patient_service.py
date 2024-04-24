
from fastapi import UploadFile
import tempfile

from util.base_publisher import RabbitMqPublisher
from fastapi import HTTPException, status


class PatientService():

    def __init__(self, rabbitmq_publisher: RabbitMqPublisher):
        self.rabbitmq_publisher = rabbitmq_publisher

    async def create_patient_membership_job(self, file: UploadFile):
            await self.save_upload_file(file)
            try:
                self.rabbitmq_publisher.send_new_patient_memberships(file.filename)
            except Exception as e:
                print(f"Error while creating memberships for file: {file.filename}")
            return

    async def create_patient_claims_job(self, file: UploadFile):
            await self.save_upload_file(file)
            try:
                self.rabbitmq_publisher.send_new_patient_claims(file.filename)
            except Exception as e:
                print(f"Error while creating claim for file: {file.filename}")
            return

    async def save_upload_file(self, file: UploadFile):
        with open(f"/uploaded-files/{str(file.filename)}", "wb") as buffer:
            buffer.write(await file.read())
            return
