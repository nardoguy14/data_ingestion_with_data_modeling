with common_formats as (select "Elig_Dt"                             as "membership_end_date",
                               "mem_id"                              as "member_id",
                               SPLIT_PART("Member_Fullname", ',', 2) AS "first_name",
                               SPLIT_PART("Member_Fullname", ',', 1) AS "last_name",
                               "Dob"                                 as "dob",
                               "Age_In_Mths_No"                      as "age_in_months",
                               "Gender"                              as "gender",
                               "Member_Address"                      as "address",
                               "Member_Address_2"                    as "address2",
                               "Member_City"                         as "city",
                               CASE
                                   WHEN states.state_code IS NOT NULL THEN states.state_code
                                   ELSE NULL
                                   END                               AS "state",
                               CASE
                                   WHEN "Member_Zip" LIKE '%[0-9]%' THEN "Member_Zip"
                                   ELSE NULL
                                   END                               AS "zip",
                               CASE
                                   WHEN "Member_Phone" LIKE '%[0-9]%' THEN "Member_Phone"
                                   ELSE NULL
                                   END                               AS "phone_number",
                               "file_defined_period"
                        from {{source("client_B_patient_source", "patient_registration_clientB")}}
    left join {{ source ('seeds', 'states')}} states
    ON "patient_registration_clientB"."Member_State" = states.state_code
)
select
       "member_id",
       "first_name",
       "last_name",
       "dob",
       "age_in_months",
       "gender",
       "address",
       "address2",
       "city",
       "state",
       "zip",
       "phone_number",
       my_to_timestamp("membership_end_date") as membership_end_date,
        "file_defined_period"
from common_formats