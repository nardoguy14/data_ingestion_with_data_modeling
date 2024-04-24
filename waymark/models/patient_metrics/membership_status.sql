{{ config(materialized='table') }}

with statuses as (
    select
        "member_id",
        "membership_end_date",
        CASE
            WHEN ('2023-08-09' <= "membership_end_date") THEN 'active'
            ELSE 'inactive'
        END AS "status"
    FROM {{ ref("patient_membership") }}
)
select *
from statuses