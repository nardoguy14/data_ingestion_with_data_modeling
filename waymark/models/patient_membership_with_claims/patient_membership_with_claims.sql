{{ config(materialized='table') }}

select
-- patient mem data
    "pat_mem"."member_id",
    "first_name",
    "middle_name",
    "last_name",
    "gender",
    "dob",
    "address",
    "city",
    "state",
    "zip",
    "phone_number",
    "membership_end_date",
    "ethnicity",
-- patient claims data
    "claim category",
    "claim_number",
    "date_received",
    "vendor",
    "hospital service",
    "coding system",
    "code",
    "primary diagnosis",
    "total billed",
    "processing status",
    "pat_mem"."file_defined_period",
    "pat_mem"."client"
from {{ ref("patient_membership") }} pat_mem
join {{ ref("patient_claims") }} pat_claims
  on "pat_claims"."member_id" = "pat_mem"."member_id" AND "pat_claims"."client" = "pat_mem"."client"