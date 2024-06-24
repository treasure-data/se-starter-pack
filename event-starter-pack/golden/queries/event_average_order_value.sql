with base as (
  select
    event_unification_id
  , event_id
  , amount
  from enriched_ticket_transactions
  union all
  select
    event_unification_id
  , event_id
  , amount
  from enriched_event_concessions_transactions
  union all
  select
    event_unification_id
  , event_id
  , amount
  from enriched_event_merchandise_transactions
),
agg as (
  select
    event_unification_id
  , count(distinct event_id) total_num_events
  , sum(amount) total_revenue
  from base
  group by event_unification_id
)
select event_unification_id
, round(total_revenue/total_num_events, 2) as event_avg_order_value
from agg