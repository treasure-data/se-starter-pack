with base as (
  select distinct retail_unification_id from parent_table
)
select coalesce(a.event_unification_id, 'no_event_unification_id') as event_unification_id
, coalesce(ltv, null) as ltv
, coalesce(merch_purchaser, 'False') as merch_purchaser
, coalesce(drink_purchaser, 'False') as drink_purchaser
, coalesce(food_purchaser, 'False') as food_purchaser
, coalesce(no_of_events_last_365, null) as no_of_events_last_365
, coalesce(last_event_datetime_unix, null) as last_event_datetime_unix
, coalesce(web_visits_last_7days, 'False') as web_visits_last_7days
, coalesce(more_than_5_softbounce, 'False') as more_than_5_softbounce
, coalesce(hardbounce, 'False') as hardbounce
, coalesce(last_email_date_unix, null) as last_email_date_unix
, coalesce(last_ticket_purchase_datetime_unix, null) as last_ticket_purchase_datetime_unix
, coalesce(avg_tickets_per_order, null) as avg_tickets_per_order
, coalesce(ticket_avg_order_value, null) as ticket_avg_order_value
, coalesce(event_avg_order_value, null) as event_avg_order_value
from base a
left join ltv b ON a.event_unification_id = b.event_unification_id
left join merch_purchaser c ON a.event_unification_id = c.event_unification_id
left join drink_purchaser d ON a.retail_unification_id = d.retail_unification_id
left join food_purchaser e ON a.retail_unification_id = e.retail_unification_id
left join number_of_events_in_last_365days f ON a.retail_unification_id = f.retail_unification_id
left join last_event_date g ON a.retail_unification_id = g.retail_unification_id
left join web_visits_last_7days h ON a.retail_unification_id = h.retail_unification_id
left join more_than_5_soft_bounces i ON a.retail_unification_id = i.retail_unification_id
left join hardbounce j ON a.retail_unification_id = j.retail_unification_id
left join last_email_date k ON a.retail_unification_id = k.retail_unification_id
left join last_ticket_purchase_date l ON a.retail_unification_id = l.retail_unification_id
left join average_tickets_per_order m ON a.retail_unification_id = m.retail_unification_id
left join ticket_average_order_value n ON a.retail_unification_id = n.retail_unification_id
left join event_average_order_value o ON a.retail_unification_id = o.retail_unification_id