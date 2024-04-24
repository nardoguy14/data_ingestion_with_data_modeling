{{ config(materialized='table') }}

select
    "member_id",
    "first_name",
    "middle_name",
    "last_name",
    "dob",
    "gender",
    "address",
    NULL AS "address2",
    "city",
    "state",
    "zip",
    "phone_number",
    "membership_end_date",
    "ethnicity",
    "file_defined_period",
    'GROUP_A' AS "client"
from {{ ref("patient_membership_client_A_latest_members_only") }}
UNION
select
    "member_id",
    "first_name",
    NULL AS "middle_name",
    "last_name",
    "dob",
    "gender",
    "address",
    "address2",
    "city",
    "state",
    "zip",
    "phone_number",
    "membership_end_date",
    NULL AS "ethnicity",
    "file_defined_period",
    'GROUP_B' AS "client"
from {{ ref("patient_membership_client_B_latest_members_only") }}