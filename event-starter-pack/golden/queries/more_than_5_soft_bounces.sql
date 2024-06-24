with base as (select
    event_unification_id
  , count(1) softbounce_count
  from enriched_email_activity
  where trfmd_activity_type = 'email_softbounced'
  group by event_unification_id
)
select distinct event_unification_id
, 'True' as more_than_5_softbounce
from base
where softbounce_count > 5