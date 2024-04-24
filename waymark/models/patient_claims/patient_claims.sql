
{{ config(materialized='table') }}

select
    "claim category",
    "member id"::text as "member_id",
    "claim number" as "claim_number",
    "date received" as "date_received",
    "vendor",
    "hospital service",
    "coding system",
    "code",
    "primary diagnosis",
    "total billed",
    "processing status",
    "file_defined_period",
    'GROUP_A' AS "client"
from {{ ref("patient_claims_client_A_cleaned_data") }}
UNION
select
    "claim category",
    "member id" as "member_id",
    "claim number" as "claim_number",
    "date received" as "date_received",
    NULL AS "vendor",
    "hospital service",
    "coding system",
    null AS "code",
    "primary diagnosis",
    "total billed",
    "processing status",
    "file_defined_period",
    'GROUP_B' AS "client"
from {{ ref("patient_claims_client_B_cleaned_data") }}
