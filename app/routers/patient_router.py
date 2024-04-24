from fastapi import APIRouter, UploadFile, File

import tempfile


patients_router = APIRouter()
from services.patient_service import PatientService
from util.base_publisher import RabbitMqPublisher

rabbit_mq_service = RabbitMqPublisher()
patient_service = PatientService(rabbit_mq_service)


@patients_router.post("/patients/membership")
async def create_patient_memberships(file: UploadFile = File(...)):
    await patient_service.create_patient_membership_job(file)


@patients_router.post("/patients/claims")
async def create_patient_claims(file: UploadFile = File(...)):
    await patient_service.create_patient_claims_job(file)