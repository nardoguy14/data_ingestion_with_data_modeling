with common_birth_dates as (
    SELECT "member id"::text,
           "member first name",
           "member middle name",
           "member last name",
           "gender",
           CAST("date of birth" AS DATE) as "date of birth",
           "address",
           "city",
           "state",
           "zip",
           "phone number",
           "membership end date",
           "ethnicity",
           "file_defined_period"
    FROM {{ source('client_A_patient_source', 'patient_registration_clientA') }}
),
common_format as (
    with missing_times as (
       select * from common_birth_dates
       WHERE "membership end date" not like '%00:00:00%'
    )
    select *
    from missing_times
    union
    select * from common_birth_dates
    WHERE "membership end date" like '%00:00:00%'
)
select * from common_format