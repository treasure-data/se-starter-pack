with base as (
  select distinct
    event_unification_id
  , event_id
  from enriched_ticket_transactions
  where from_unixtime(trfmd_event_datetime_unix) < current_date
  union all
  select distinct
    event_unification_id
  , event_id
  from enriched_ticket_transactions
  where from_unixtime(trfmd_order_datetime_unix) < current_date
  union all
  select distinct
    event_unification_id
  , event_id
  from enriched_event_merchandise_transactions
  where from_unixtime(trfmd_order_datetime_unix) < current_date
)
select event_unification_id, count(distinct event_id) no_of_events_last_365
from base
group by event_unification_id