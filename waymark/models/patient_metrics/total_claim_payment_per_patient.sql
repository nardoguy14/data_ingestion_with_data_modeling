{{ config(materialized='table') }}

select
    "member_id",
    sum("total billed") as total_claims_payment
from {{ ref("patient_membership_with_claims") }}
group by "member_id"
