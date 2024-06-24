select
  distinct event_unification_id
  , 'True' as hardbounce
from enriched_email_activity
where trfmd_activity_type = 'email_hardbounced'