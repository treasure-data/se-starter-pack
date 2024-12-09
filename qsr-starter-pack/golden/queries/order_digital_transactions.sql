with items_arr as (
 select order_no, array_agg(product_name) as order_items from order_details group by 1
)

select 
t1.*, 
HOUR(FROM_UNIXTIME(t1.trfmd_order_datetime_unix)) as hour_of_day,
order_items
from 
order_digital_transactions  t1
left join 
(select * from items_arr) t2
on 
t1.order_no = t2.order_no
