select
trfmd_email as id,
'email' as type,
'email' as trfmd_consent_type,
retail_unification_id as retail_unification_id,
case when consent_type = 'email' then 1
else 0 
end as consent_flag
from ${uni}_${meta}.enriched_consents

UNION ALL

select
trfmd_phone_number as id,
'phone' as type,
'phone' as consent_type,
retail_unification_id as retail_unification_id,
case when consent_type = 'phone' then 1
else 0 
end as consent_flag
from ${uni}_${meta}.enriched_consents
