select
    event_unification_id
  , max(trfmd_activity_date_unix) last_email_date_unix
from enriched_email_activity
where trfmd_activity_type = 'email_sent'
group by event_unification_id