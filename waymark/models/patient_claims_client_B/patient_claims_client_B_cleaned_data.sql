select
    "claim_category" as "claim category",
    "memb_id" as "member id",
    "claim_number" as "claim number",
    "received_date" as "date received",
    "hospital_service" as "hospital service",
    "code_system" as "coding system",
    "code",
    "diagnosis_type" as "primary diagnosis",
    "cost_total" as "total billed",
    "status" as "processing status",
    "file_defined_period"
from {{source("client_B_claims_source", "patient_claims_clientB")}}
where "claim_number" IS NOT NULL