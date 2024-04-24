{{ config(materialized='table') }}

select
    "member_id",
    "claim_number",
    "primary diagnosis" as "primary_diagnosis",
    CASE
        WHEN (lower("primary diagnosis") like '%diabetes mellitus%' OR
              lower("primary diagnosis") like '%hypertension%' OR
              lower("primary diagnosis") like '%cerebrovascular%'  OR
              lower("primary diagnosis") like '%asthma%'
            )
            THEN 'Chronic disease'
        WHEN (lower("primary diagnosis") like '%depressive%' OR
              lower("primary diagnosis") like '%depression%' OR
              lower("primary diagnosis") like '%opioid%'
            )
            THEN 'Behavioral disorder'
        ELSE 'Others'
        END AS "diagnosis_type"
from {{ ref("patient_membership_with_claims") }}
