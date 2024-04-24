select
    "member id" as "member_id",
    "member first name" as "first_name",
    "member middle name" as "middle_name",
    "member last name" as "last_name",
    CASE
        WHEN gender = 'M' or gender = 'F' THEN gender
        ELSE NULL
    END AS "gender",
    CASE
        WHEN CAST("date of birth" AS DATE) <= CURRENT_DATE THEN CAST("date of birth" AS DATE)
        ELSE NULL
    END AS "dob",
    REPLACE("address", E'\u00A0', '') as "address",
    "city",
    CASE
        WHEN states.state_code IS NOT NULL THEN states.state_code
        ELSE NULL
    END AS "state",
    CASE
        WHEN zips.zip IS NOT NULL THEN zips.zip
        ELSE NULL
    END AS "zip",
    "phone number" as "phone_number",
    "membership end date" as "membership_end_date",
    "ethnicity",
    "file_defined_period"
from
{{ref("patient_membership_client_A_common_format_dates")}} common_formats
left join {{ source('seeds', 'zips') }} zips ON common_formats.zip = CAST(zips.zip AS TEXT)
left join {{ source('seeds', 'states')}} states ON common_formats.state = states.state_code
