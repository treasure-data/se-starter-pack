select
trfmd_email as id,
trfmd_id_type,
trfmd_consent_type,
${unification_id},
trfmd_consent_flag
from cdp_unification_${sub}.enriched_consents_email

UNION ALL

select
trfmd_phone_number as id,
trfmd_id_type,
trfmd_consent_type,
${unification_id},
trfmd_consent_flag
from cdp_unification_${sub}.enriched_consents_phone