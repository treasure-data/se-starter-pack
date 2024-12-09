
with 
base_1 as (select distinct ${unification_id} from parent_table ),

transactions_cte as (
    select
        *,
        date_diff(
            'day',
            LAG(FROM_UNIXTIME(trfmd_order_datetime_unix)) OVER (
                PARTITION BY ${unification_id}
                ORDER BY
                    trfmd_order_datetime_unix
            ),
            FROM_UNIXTIME(trfmd_order_datetime_unix)
        ) as days_between_transactions
    from
        (
            select
                ${unification_id},
                trfmd_order_datetime_unix,
                amount,
                trfmd_season,
                order_no,
                'Digital' as type
            from
                order_digital_transactions -- comment out section if only using one transaction table
            union
            all
            select
                ${unification_id},
                trfmd_order_datetime_unix,
                amount,
                trfmd_season,
                order_no,
                'Offline' as type
            from
                order_offline_transactions -- comment out section if only using one transaction table
        )
),

preferred_season_cte as (
    select
        ${unification_id},
        trfmd_season,
        MAX(trfmd_order_datetime_unix) AS last_purchase_date,
        count(
            CASE
                WHEN trfmd_season is not null THEN order_no
                ELSE NULL
            END
        ) AS preferred_season_cnt
    from
        transactions_cte
    group by
        1,
        2
),

transactions_attributes as (
  select
    ${unification_id},
    max(CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix ELSE NULL END) AS last_purchase_date_unix,
    max(CASE WHEN type = 'Offline' THEN trfmd_order_datetime_unix ELSE NULL END) AS last_instore_purchase_date_unix,
    count(distinct case when  amount > 0.0 then order_no ELSE null END) as total_purchases,
    min(
        CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix 
        ELSE NULL END
    ) as first_purchase_date_unix,
    count(distinct 
        CASE WHEN trfmd_order_datetime_unix >= try_cast(to_unixtime(date_trunc('day', now()) - interval '30' day) as integer) THEN order_no 
        ELSE NULL END
    ) AS purchases_last_30days,
    round(sum(CASE WHEN amount is not null THEN amount ELSE NULL END), 2) AS ltv,
    round(avg(CASE WHEN amount is not null THEN amount ELSE NULL END), 2) AS aov,
    ROUND(AVG(days_between_transactions)) as avg_days_between_transactions
 from
transactions_cte
group by 
${unification_id}
),

purchase_interval as (
  select ${unification_id}
    ,total_purchases
    ,DATE_DIFF('day', from_unixtime(last_purchase_date_unix), CURRENT_TIMESTAMP) as time_since_last_purchase
    ,DATE_DIFF('day', from_unixtime(first_purchase_date_unix), from_unixtime(last_purchase_date_unix)) AS purchase_period
    from transactions_attributes
    where total_purchases > 2
),
purchase_average as (
  select ${unification_id}
    ,AVG(purchase_period/(total_purchases-1)) as average_purchase
    ,max(time_since_last_purchase) as time_since_last_purchase
  from purchase_interval
  group by ${unification_id}
),

preferred_season_attributes as (
    select
        ${unification_id},
        trfmd_season as preferred_season
    from
        (
            select
                ${unification_id},
                trfmd_season,
                row_number() over (
                    partition by ${unification_id}
                    order by
                        preferred_season_cnt,
                        last_purchase_date desc
                ) as rnk
            from
                preferred_season_cte
        ) x
    where
        rnk = 1
)

select 
    coalesce(base_1.${unification_id}, 'no_unification_id') as ${unification_id}, 
    coalesce(aov, null) as aov,
    coalesce(last_purchase_date_unix, null) as last_purchase_date_unix,
    coalesce(last_instore_purchase_date_unix, null) as last_instore_purchase_date_unix,
    coalesce(ltv, null) as ltv,
    coalesce(preferred_season, null) as preferred_season,
    coalesce(purchases_last_30days, null) as purchases_last_30days,
    coalesce(avg_days_between_transactions, null) as avg_days_between_transactions,
    coalesce(total_purchases, null) as total_purchases,
    case
        when time_since_last_purchase > (average_purchase + ceiling(0.1*average_purchase)) then 'Yes' 
        ELSE 'No' 
    END as churn_risk
from base_1
left join transactions_attributes ON base_1.${unification_id} = transactions_attributes.${unification_id}
left join preferred_season_attributes ON base_1.${unification_id} = preferred_season_attributes.${unification_id}
left join purchase_average ON base_1.${unification_id} = purchase_average.${unification_id};
