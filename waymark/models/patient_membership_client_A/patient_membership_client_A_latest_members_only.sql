
WITH only_valid_dates as (
    SELECT *,
           my_to_timestamp("membership_end_date") as casted_timestamp
    FROM {{ ref("patient_membership_client_A_cleaned_data") }}
),
 RankedMembers AS (
     SELECT *,
            ROW_NUMBER() OVER (PARTITION BY "member_id" ORDER BY "membership_end_date" DESC) AS rn
     FROM only_valid_dates
     WHERE casted_timestamp is not null
 )
SELECT
    "member_id",
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
    "casted_timestamp" as "membership_end_date",
    "ethnicity",
    "file_defined_period"
FROM RankedMembers
WHERE rn = 1
