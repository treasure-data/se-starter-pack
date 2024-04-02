with enriched_pageviews_cte_attributor as (select
time as time,
retail_unification_id as retail_unification_id
 from enriched_pageviews),

enriched_order_offline_transactions_enriched_order_online_transactions_cte_attributor as (select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_offline_transactions
 union all
select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_online_transactions),

enriched_email_activity_cte_attributor as (select
time as time,
retail_unification_id as retail_unification_id,
activity_type as activity_type
 from enriched_email_activity),

enriched_order_details_cte_attributor as (select
retail_unification_id as retail_unification_id,
retail_price as retail_price
 from enriched_order_details),

enriched_order_offline_transactions_cte_attributor as (select
retail_unification_id as retail_unification_id,
order_datetime as order_datetime
 from enriched_order_offline_transactions),

pre_preferred_season_cte_attributor as (select
season as season,
retail_unification_id as retail_unification_id,
preferred_season_cnt as preferred_season_cnt
 from pre_preferred_season),

enriched_email_activity_agg_cte_attributor as (select
retail_unification_id,
max(CASE WHEN lower(activity_type) = 'email_sent' THEN time ELSE NULL END) AS last_email_date,
count(CASE WHEN lower(activity_type) = 'email_hardbounced' THEN activity_type ELSE NULL END) AS email_hardbounce
 from
enriched_email_activity_cte_attributor
group by retail_unification_id),

enriched_email_activity_1_rnk_cte_attributor as (select
retail_unification_id,
activity_type as email_softbounce_gt5
from (select
retail_unification_id,
activity_type,
row_number() over (partition by retail_unification_id order by time desc) as rnk
from
enriched_email_activity_cte_attributor
where lower(activity_type) = 'email_softbounced') x
where rnk = 6),

enriched_order_offline_transactions_agg_cte_attributor as (select
retail_unification_id,
max(CASE WHEN order_datetime is not null THEN order_datetime ELSE NULL END) AS last_store_visit
 from
enriched_order_offline_transactions_cte_attributor
group by retail_unification_id),

pre_preferred_season_2_rnk_cte_attributor as (select
retail_unification_id,
season as preferred_season
from (select
retail_unification_id,
season,
row_number() over (partition by retail_unification_id order by preferred_season_cnt desc) as rnk
from
pre_preferred_season_cte_attributor
) x
where rnk = 1),

enriched_pageviews_agg_cte_attributor as (select
retail_unification_id,
count(CASE WHEN time >= try_cast(to_unixtime(date_trunc('day', now()) - interval '7' day) as integer) THEN retail_unification_id ELSE NULL END) AS web_visits_last_7days
 from
enriched_pageviews_cte_attributor
group by retail_unification_id),

enriched_order_details_agg_cte_attributor as (select
retail_unification_id,
sum(CASE WHEN retail_price is not null THEN retail_price ELSE NULL END) AS ltv,
avg(CASE WHEN retail_price is not null THEN retail_price ELSE NULL END) AS aov
 from
enriched_order_details_cte_attributor
group by retail_unification_id),

enriched_order_offline_transactions_enriched_order_online_transactions_agg_cte_attributor as (select
retail_unification_id,
max(CASE WHEN order_datetime is not null THEN order_datetime ELSE NULL END) AS last_purchase_date,
count(CASE WHEN order_datetime >= try_cast(to_unixtime(date_trunc('day', now()) - interval '30' day) as integer) THEN retail_unification_id ELSE NULL END) AS purchases_last_30days
 from
enriched_order_offline_transactions_enriched_order_online_transactions_cte_attributor
group by retail_unification_id),

base_1 as (select distinct retail_unification_id from parent_table )
select coalesce(base_1.retail_unification_id, 'no_retail_unification_id') as retail_unification_id, coalesce(aov, null) as aov,
coalesce(email_hardbounce, null) as email_hardbounce,
coalesce(email_softbounce_gt5, null) as email_softbounce_gt5,
coalesce(last_email_date, null) as last_email_date,
coalesce(last_purchase_date, null) as last_purchase_date,
coalesce(last_store_visit, null) as last_store_visit,
coalesce(ltv, null) as ltv,
coalesce(preferred_season, null) as preferred_season,
coalesce(purchases_last_30days, null) as purchases_last_30days,
coalesce(web_visits_last_7days, null) as web_visits_last_7days from base_1 left join enriched_order_offline_transactions_enriched_order_online_transactions_agg_cte_attributor ON base_1.retail_unification_id = enriched_order_offline_transactions_enriched_order_online_transactions_agg_cte_attributor.retail_unification_id
left join pre_preferred_season_2_rnk_cte_attributor ON base_1.retail_unification_id = pre_preferred_season_2_rnk_cte_attributor.retail_unification_id
left join enriched_email_activity_agg_cte_attributor ON base_1.retail_unification_id = enriched_email_activity_agg_cte_attributor.retail_unification_id
left join enriched_pageviews_agg_cte_attributor ON base_1.retail_unification_id = enriched_pageviews_agg_cte_attributor.retail_unification_id
left join enriched_order_offline_transactions_agg_cte_attributor ON base_1.retail_unification_id = enriched_order_offline_transactions_agg_cte_attributor.retail_unification_id
left join enriched_order_details_agg_cte_attributor ON base_1.retail_unification_id = enriched_order_details_agg_cte_attributor.retail_unification_id
left join enriched_email_activity_1_rnk_cte_attributor ON base_1.retail_unification_id = enriched_email_activity_1_rnk_cte_attributor.retail_unification_id;

