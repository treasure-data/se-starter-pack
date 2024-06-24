with base as (
  select
    event_unification_id
  , amount
  from enriched_ticket_transactions
  union all
  select
    event_unification_id
  , amount
  from enriched_event_concessions_transactions
  union all
  select
    event_unification_id
  , amount
  from enriched_event_merchandise_transactions
  union all
  select
    event_unification_id
  , amount
  from enriched_online_merchandise_transactions
)
select
  event_unification_id
, round(sum(amount), 2) as ltv
from base
group by event_unification_id