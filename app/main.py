from fastapi import FastAPI, File, UploadFile
from routers.patient_router import patients_router
import tempfile

app = FastAPI()

app.include_router(patients_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
