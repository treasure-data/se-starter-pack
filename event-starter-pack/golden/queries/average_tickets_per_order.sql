with base as (select
    event_unification_id
  , count(distinct order_no) total_num_orders
  , sum(quantity) total_num_tickets
  from enriched_ticket_transactions
  group by event_unification_id
)
select event_unification_id
, round(total_num_tickets/total_num_orders, 2) as avg_tickets_per_order
from base