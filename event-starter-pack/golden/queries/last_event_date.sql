with base as (
  select
    event_unification_id
  , max(trfmd_event_datetime_unix) as event_datetime_unix
  from enriched_ticket_transactions
  group by event_unification_id
  union all
  select
    event_unification_id
  , max(trfmd_order_datetime_unix ) as event_datetime_unix
  from enriched_ticket_transactions
  group by event_unification_id
  union all
  select
    event_unification_id
  , max(trfmd_order_datetime_unix ) as event_datetime_unix
  from enriched_event_concessions_transactions
  group by event_unification_id
)
select event_unification_id, max(event_datetime_unix) as last_event_datetime_unix
from base
group by event_unification_id