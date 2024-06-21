select
trfmd_email as id,
trfmd_id_type,
trfmd_consent_type,
event_unification_id,
trfmd_consent_flag
from enriched_consents_email

UNION ALL

select
trfmd_phone_number as id,
trfmd_id_type,
trfmd_consent_type,
retail_unification_id,
event_consent_flag
from enriched_consents_phone