with pageviews_cte as (select
time as time,
retail_unification_id as retail_unification_id
 from enriched_pageviews),

transactions_cte as (select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_offline_transactions
 union all
select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_online_transactions),

email_cte as (select
time as time,
retail_unification_id as retail_unification_id,
activity_type as activity_type
 from enriched_email_activity),

order_details_cte as (select
retail_unification_id as retail_unification_id,
retail_price as retail_price
 from enriched_order_details),

offline_transactions_cte as (select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_offline_transactions),

preferred_season_cte as (select
season as season,
retail_unification_id as retail_unification_id,
preferred_season_cnt as preferred_season_cnt
 from pre_preferred_season),

email_attributes as (select
retail_unification_id,
max(CASE WHEN lower(activity_type) = 'email_sent' THEN time ELSE NULL END) AS last_email_date,
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
row_number() over (partition by retail_unification_id order by time desc) as rnk
from
email_cte
where lower(activity_type) = 'email_softbounced') x
where rnk = 6),

offline_transactions_attributes as (select
retail_unification_id,
max(CASE WHEN order_datetime is not null THEN order_datetime ELSE NULL END) AS last_store_visit
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

order_details_attributes as (select
retail_unification_id,
sum(CASE WHEN retail_price is not null THEN retail_price ELSE NULL END) AS ltv,
avg(CASE WHEN retail_price is not null THEN retail_price ELSE NULL END) AS aov
 from
order_details_cte
group by retail_unification_id),

transactions_attributes as (select
retail_unification_id,
max(CASE WHEN order_datetime is not null THEN order_datetime ELSE NULL END) AS last_purchase_date,
count(CASE WHEN order_datetime >= try_cast(to_unixtime(date_trunc('day', now()) - interval '30' day) as integer) THEN retail_unification_id ELSE NULL END) AS purchases_last_30days
 from
transactions_cte
group by retail_unification_id),

base_1 as (select distinct retail_unification_id from parent_table )

select coalesce(base_1.retail_unification_id, 'no_retail_unification_id') as retail_unification_id, coalesce(aov, null) as aov,
case when coalesce(email_hardbounce, null) > 0 then 'True' else 'False' end as email_hardbounce,
case when coalesce(email_softbounce_gt5, null) then 'True' else 'False' end as email_softbounce_gt5,
coalesce(last_email_date, null) as last_email_date,
coalesce(last_purchase_date, null) as last_purchase_date,
coalesce(last_store_visit, null) as last_store_visit,
coalesce(ltv, null) as ltv,
coalesce(preferred_season, null) as preferred_season,
coalesce(purchases_last_30days, null) as purchases_last_30days,
coalesce(web_visits_last_7days, null) as web_visits_last_7days
from base_1
left join transactions_attributes ON base_1.retail_unification_id = transactions_attributes.retail_unification_id
left join preferred_season_attributes ON base_1.retail_unification_id = preferred_season_attributes.retail_unification_id
left join email_attributes ON base_1.retail_unification_id = email_attributes.retail_unification_id
left join pageviews_attributes ON base_1.retail_unification_id = pageviews_attributes.retail_unification_id
left join offline_transactions_attributes ON base_1.retail_unification_id = offline_transactions_attributes.retail_unification_id
left join order_details_attributes ON base_1.retail_unification_id = order_details_attributes.retail_unification_id
left join email_attributes_2 ON base_1.retail_unification_id = email_attributes_2.retail_unification_id;