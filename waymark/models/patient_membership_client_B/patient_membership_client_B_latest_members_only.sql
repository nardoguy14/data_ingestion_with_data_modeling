
WITH RankedMembers AS (
         SELECT *,
                ROW_NUMBER() OVER (PARTITION BY "member_id" ORDER BY "membership_end_date" DESC) AS rn
         FROM {{ ref("patient_membership_client_B_common_formats") }}
         WHERE membership_end_date is not null
     )
SELECT
    "member_id",
    "first_name",
    "last_name",
    "dob"::DATE,
    "age_in_months",
    "gender",
    "address",
    "address2",
    "city",
    "state",
    "zip"::INTEGER,
    "phone_number"::BIGINT,
    "membership_end_date",
    "file_defined_period"
FROM RankedMembers
WHERE rn = 1
