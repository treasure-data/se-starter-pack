drop table if exists ${stg}_${sub}.${tbl};

create table ${stg}_${sub}.${tbl} as

SELECT *,
    -- BIGINT field: ensure it's not negative
    CASE WHEN time IS NULL OR time < 0 THEN NULL ELSE time END AS trfmd_time,

    -- Phone number: remove non-numeric characters
    CASE 
        WHEN nullif(lower(trim(phone_number)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(phone_number), '') IS NULL THEN NULL
        ELSE regexp_replace(trim(phone_number), '[^0-9]', '')
    END AS trfmd_phone_number,

    -- Email: lowercase and remove invalid characters
    CASE 
        WHEN nullif(lower(trim(email)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(email), '') IS NULL THEN NULL
        ELSE lower(trim(regexp_replace(email, '[^a-zA-Z0-9.@_+-]', '')))
    END AS trfmd_email,

    -- String fields: trim, convert to title case, and nullify if empty or 'null'
    CASE 
        WHEN nullif(lower(trim(regexp_replace(activity_type, '[._]', ' '))), 'null') IS NULL THEN NULL
        WHEN nullif(trim(regexp_replace(activity_type, '[._]', ' ')), '') IS NULL THEN NULL
        ELSE regexp_replace(lower(trim(regexp_replace(activity_type, '[._]', ' '))), '(^|\s)([a-z])', x -> upper(x[2]))
    END AS trfmd_activity_type,

    CASE 
        WHEN nullif(lower(trim(message_type)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(message_type), '') IS NULL THEN NULL
        ELSE regexp_replace(lower(trim(message_type)), '(^|\s)([a-z])', x -> upper(x[2]))
    END AS trfmd_message_type,

    CASE 
        WHEN nullif(lower(trim(message_name)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(message_name), '') IS NULL THEN NULL
        ELSE regexp_replace(lower(trim(message_name)), '(^|\s)([a-z])', x -> upper(x[2]))
    END AS trfmd_message_name,

    -- Message text: just trim and nullify if empty or 'null'
    CASE 
        WHEN nullif(lower(trim(message_text)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(message_text), '') IS NULL THEN NULL
        ELSE trim(message_text)
    END AS trfmd_message_text,

    -- Message link: lowercase and trim
    CASE 
        WHEN nullif(lower(trim(message_link)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(message_link), '') IS NULL THEN NULL
        ELSE lower(trim(message_link))
    END AS trfmd_message_link,

    -- Message creative: trim and nullify if empty or 'null'
    CASE 
        WHEN nullif(lower(trim(message_creative)), 'null') IS NULL THEN NULL
        WHEN nullif(trim(message_creative), '') IS NULL THEN NULL
        ELSE trim(message_creative)
    END AS trfmd_message_creative

FROM sms_activity