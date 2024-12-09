with known_cust as (
  select distinct retail_unification_id as  kc
  from profile_identifiers where email is not null
),
all_web_cust as (
  select distinct retail_unification_id as wc
  from pageviews
  where TD_INTERVAL(time, '-1d')
),
total_sales as (
(
  select sum(amount) as amount from (
      select sum(amount) as amount
        from order_offline_transactions
        where TD_INTERVAL(trfmd_order_datetime_unix, '-1d')
        union all
        select sum(amount) as amount
        from order_digital_transactions
        where TD_INTERVAL(trfmd_order_datetime_unix, '-1d')
  )
)
),
new_cust_cnt as (
  select count(distinct b.wc) new_customer_cnt
  from known_cust a full outer join all_web_cust b
  on (a.kc = b.wc)
  where a.kc is null
)
select
  DATE_FORMAT(current_date,  '%Y-%m-%d 00:00:00.0') as run_date
, known_cust_cnt
, new_customer_cnt
, round(amount, 2) total_sales
from (select count(kc) as known_cust_cnt from known_cust) , new_cust_cnt, total_sales