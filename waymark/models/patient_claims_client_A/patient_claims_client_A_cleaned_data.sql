
select
    "claim category",
    "member id"::text,
    "claim number",
    "date received",
    "vendor",
    "hospital service",
    "coding system",
    "code",
    "primary diagnosis",
    "total billed",
    "processing status",
    "file_defined_period"
from {{source('client_A_claims_source', 'patient_claims_clientA')}}
where "claim number" IS NOT NULL