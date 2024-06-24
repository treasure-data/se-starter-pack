with base as (select
    event_unification_id
  , count(distinct order_no) total_num_orders
  , sum(amount) total_revenue
  from enriched_ticket_transactions
  group by event_unification_id
)
select event_unification_id
, round(total_revenue/total_num_orders, 2) as ticket_avg_order_value
from base