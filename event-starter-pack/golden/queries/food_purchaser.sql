select distinct event_unification_id, 'True' as food_purchaser
from enriched_event_concessions_order_details
where trfmd_product_department = 'Food'