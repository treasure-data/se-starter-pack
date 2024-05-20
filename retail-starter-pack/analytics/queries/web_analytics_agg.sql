with cal as (
  select DATE_FORMAT(date_add('day', -1, current_date), '%Y-%m-%d') st_dt,
            DATE_FORMAT(current_date, '%Y-%m-%d') end_dt,
          DATE_FORMAT(current_date,  '%Y-%m-%d 00:00:00.0') today_datetime
)
,known_cust as (
  select distinct retail_unification_id as  kc
  from enriched_customers
),
all_web_cust as (
  select distinct retail_unification_id as wc
  from enriched_pageviews, cal
  where TD_TIME_RANGE(time, st_dt , end_dt)
),
total_sales as (
(
  select sum(amount) as amount from (
      select sum(amount) as amount
        from enriched_order_offline_transactions, cal
        where TD_TIME_RANGE(order_datetime, st_dt , end_dt)
        union all
        select sum(amount) as amount
        from enriched_order_online_transactions, cal
        where TD_TIME_RANGE(order_datetime, st_dt , end_dt)
  )
)
),
new_cust_cnt as (
  select count(distinct b.wc) new_customer_cnt
  from known_cust a full outer join all_web_cust b
  on (a.kc = b.wc)
  where a.kc is null
)
select today_datetime as run_date, known_cust_cnt,  new_customer_cnt, round(amount, 2) total_sales
from (select count(kc) as known_cust_cnt from known_cust) , new_cust_cnt, total_sales, cal