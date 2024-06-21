-- Ticket Average Order Value --done
-- Event Average Order Value
-- Average Tickets Per Order --done
-- Last Ticket Purchase Date --done
-- Web Visits in Last 7 Days --done
-- No. of Events in Last 365 Days
-- https://hub.docker.com/layers/library/python/3.12.4-alpine3.20/images/sha256-4390b9ecec62e2be0dc50a034aeb418968a37477b9d0e4e5914a42d1840850df?context=repo&tab=vulnerabilities
-- Drink Purchaser
-- Merch Purchaser
-- LTV --
-- Last Event Date
-- Last Email Date --done
-- Hardbounce --done
-- More Than 5 Soft bounces --done

with pageviews_cte as (select
time as time,
retail_unification_id as retail_unification_id
 from enriched_pageviews),

transactions_cte as (
select
  *,
  date_diff('day', LAG(FROM_UNIXTIME(trfmd_order_datetime_unix)) OVER (PARTITION BY retail_unification_id ORDER BY trfmd_order_datetime_unix), FROM_UNIXTIME(trfmd_order_datetime_unix)) as days_between_transactions
from
(
  select
    retail_unification_id as retail_unification_id,
    trfmd_order_datetime_unix as trfmd_order_datetime_unix,
    amount as amount
    from enriched_order_offline_transactions
    union all
    select
    retail_unification_id as retail_unification_id,
    trfmd_order_datetime_unix as trfmd_order_datetime_unix,
    amount as amount
    from enriched_order_online_transactions
)
 ),

email_cte as (select
trfmd_activity_date_unix as trfmd_activity_date_unix,
retail_unification_id as retail_unification_id,
activity_type as activity_type
 from enriched_email_activity),

offline_transactions_cte as (select
retail_unification_id as retail_unification_id,
trfmd_order_datetime_unix as trfmd_order_datetime_unix
 from enriched_order_offline_transactions),

preferred_season_cte as (select
season as season,
retail_unification_id as retail_unification_id,
preferred_season_cnt as preferred_season_cnt
 from pre_preferred_season),

email_attributes as (select
retail_unification_id,
max(CASE WHEN lower(activity_type) = 'email_sent' THEN trfmd_activity_date_unix ELSE NULL END) AS last_email_date_unix,
count(CASE WHEN lower(activity_type) = 'email_hardbounced' THEN activity_type ELSE NULL END) AS email_hardbounce
 from
email_cte
group by retail_unification_id),

email_attributes_2 as (select
retail_unification_id,
activity_type as email_softbounce_gt5
from (select
retail_unification_id,
activity_type,
row_number() over (partition by retail_unification_id order by trfmd_activity_date_unix desc) as rnk
from
email_cte
where lower(activity_type) = 'email_softbounced') x
where rnk = 6),

offline_transactions_attributes as (select
retail_unification_id,
max(CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix ELSE NULL END) AS last_store_visit_unix
 from
offline_transactions_cte
group by retail_unification_id),

 preferred_season_attributes as (select
retail_unification_id,
season as preferred_season
from (select
retail_unification_id,
season,
row_number() over (partition by retail_unification_id order by preferred_season_cnt desc) as rnk
from
preferred_season_cte
) x
where rnk = 1),

pageviews_attributes as (select
retail_unification_id,
count(CASE WHEN time >= try_cast(to_unixtime(date_trunc('day', now()) - interval '7' day) as integer) THEN retail_unification_id ELSE NULL END) AS web_visits_last_7days

 from
pageviews_cte
group by retail_unification_id),

transactions_attributes as (
  select
retail_unification_id,
max(CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix ELSE NULL END) AS last_purchase_date_unix,
count(case when trfmd_order_datetime_unix is not null then retail_unification_id ELSE null END) as total_purchases,
min(CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix ELSE NULL END) as first_purchase_date_unix,
count(CASE WHEN trfmd_order_datetime_unix >= try_cast(to_unixtime(date_trunc('day', now()) - interval '30' day) as integer) THEN retail_unification_id ELSE NULL END) AS purchases_last_30days,
sum(CASE WHEN amount is not null THEN amount ELSE NULL END) AS ltv,
avg(CASE WHEN amount is not null THEN amount ELSE NULL END) AS aov,
ROUND(AVG(days_between_transactions)) as avg_days_between_transactions
 from
transactions_cte
group by retail_unification_id
),

base_1 as (select distinct retail_unification_id from parent_table ),

purchase_interval as (
  select retail_unification_id
    ,total_purchases
    ,DATE_DIFF('day', from_unixtime(last_purchase_date_unix), CURRENT_TIMESTAMP) as time_since_last_purchase
    ,DATE_DIFF('day', from_unixtime(first_purchase_date_unix), from_unixtime(last_purchase_date_unix)) AS purchase_period
    from transactions_attributes
    where total_purchases > 2
),
purchase_average as (
  select retail_unification_id
    ,AVG(purchase_period/(total_purchases-1)) as average_purchase
    ,max(time_since_last_purchase) as time_since_last_purchase
  from purchase_interval
  group by retail_unification_id
)

select coalesce(base_1.event_unification_id, 'no_event_unification_id') as event_unification_id
, coalesce(aov, null) as aov
, case when coalesce(email_hardbounce, null) > 0 then 'True' else 'False' end as email_hardbounce
, case when coalesce(email_softbounce_gt5, null) = 'email_softbounced' then 'True' else 'False' end as email_softbounce_gt5,
, coalesce(last_email_date_unix, null) as last_email_date_unix,
coalesce(last_purchase_date_unix, null) as last_purchase_date_unix,
coalesce(last_store_visit_unix, null) as last_store_visit_unix,
coalesce(ltv, null) as ltv,
coalesce(preferred_season, null) as preferred_season,
coalesce(purchases_last_30days, null) as purchases_last_30days,
coalesce(web_visits_last_7days, null) as web_visits_last_7days,


coalesce(avg_days_between_transactions, null) as avg_days_between_transactions,
case when time_since_last_purchase > (average_purchase + ceiling(0.1*average_purchase)) then 'Yes' ELSE 'No' END as churn_risk
from base_1
left join transactions_attributes ON base_1.retail_unification_id = transactions_attributes.retail_unification_id
left join preferred_season_attributes ON base_1.retail_unification_id = preferred_season_attributes.retail_unification_id
left join email_attributes ON base_1.retail_unification_id = email_attributes.retail_unification_id
left join pageviews_attributes ON base_1.retail_unification_id = pageviews_attributes.retail_unification_id
left join offline_transactions_attributes ON base_1.retail_unification_id = offline_transactions_attributes.retail_unification_id
left join email_attributes_2 ON base_1.retail_unification_id = email_attributes_2.retail_unification_id
left join purchase_average ON base_1.retail_unification_id = purchase_average.retail_unification_id;