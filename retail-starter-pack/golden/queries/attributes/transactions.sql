
with 
base_1 as (select distinct ${unification_id} from parent_table ),

transactions_cte as (
    select
        *
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
          count(distinct 
          CASE WHEN trfmd_order_datetime_unix >= try_cast(to_unixtime(date_trunc('day', now()) - interval '180' day) as integer) THEN order_no 
          ELSE NULL END
      ) AS purchases_last_180days,
      count(distinct 
          CASE WHEN trfmd_order_datetime_unix >= try_cast(to_unixtime(date_trunc('day', now()) - interval '365' day) as integer) THEN order_no 
          ELSE NULL END
      ) AS purchases_last_365days,      
      round(sum(CASE WHEN amount is not null THEN amount ELSE NULL END), 2) AS ltv,
      round(avg(CASE WHEN amount is not null THEN amount ELSE NULL END), 2) AS aov
  from
  transactions_cte
  group by 
  ${unification_id}

),

last_purchase_attributes as (
  select 
    trn.${unification_id}, 
     -- Purchases 0-30 days before last purchase
    COUNT(DISTINCT 
      CASE 
        WHEN trfmd_order_datetime_unix > (last_purchase_date_unix - 30 * 86400)
        AND trfmd_order_datetime_unix <= last_purchase_date_unix
        THEN order_no 
      END
    ) AS purchases_0_30d_before_last,
    
    -- Purchases 30-90 days before last purchase  
    COUNT(DISTINCT 
      CASE 
        WHEN trfmd_order_datetime_unix > (last_purchase_date_unix - 90 * 86400)
        AND trfmd_order_datetime_unix <= (last_purchase_date_unix - 30 * 86400)
        THEN order_no 
      END
    ) AS purchases_30_90d_before_last,
    
    -- Purchases 90-180 days before last purchase
    COUNT(DISTINCT 
      CASE 
        WHEN trfmd_order_datetime_unix > (last_purchase_date_unix - 180 * 86400)
        AND trfmd_order_datetime_unix <= (last_purchase_date_unix - 90 * 86400)
        THEN order_no 
      END
    ) AS purchases_90_180d_before_last,
    
    -- Purchases 180-365 days before last purchase
    COUNT(DISTINCT 
      CASE 
        WHEN trfmd_order_datetime_unix > (last_purchase_date_unix - 365 * 86400)
        AND trfmd_order_datetime_unix <= (last_purchase_date_unix - 180 * 86400)
        THEN order_no 
      END
    ) AS purchases_180_365d_before_last
  FROM 
    transactions_cte trn
      left join 
      (select ${unification_id}, last_purchase_date_unix from transactions_attributes) attr 
    on trn.${unification_id} = attr.${unification_id}
  GROUP BY trn.${unification_id}
),

purchase_interval as (
  select ${unification_id}
    ,total_purchases
    ,DATE_DIFF('day', from_unixtime(last_purchase_date_unix), CURRENT_TIMESTAMP) as days_since_last_purchase
    ,DATE_DIFF('day', from_unixtime(first_purchase_date_unix), from_unixtime(last_purchase_date_unix)) AS purchase_period
    from transactions_attributes
    where total_purchases > 2
),
purchase_average as (
  select ${unification_id}
    ,AVG(purchase_period/(total_purchases-1)) as avg_days_between_transactions
    ,max(days_since_last_purchase) as days_since_last_purchase
    ,max(days_since_last_purchase)/AVG(purchase_period/(total_purchases-1)) as recency_ratio_score
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
    date_diff('day', from_unixtime(last_purchase_date_unix), current_date) as days_since_last_purchase,
    coalesce(last_instore_purchase_date_unix, null) as last_instore_purchase_date_unix,
    coalesce(ltv, null) as ltv,
    coalesce(preferred_season, null) as preferred_season,
    coalesce(purchases_last_30days, null) as purchases_last_30days,
    coalesce(purchases_last_180days, null) as purchases_last_180days,
    coalesce(purchases_last_365days, null) as purchases_last_365days,
    CASE WHEN purchases_last_365days > 0 THEN 
      coalesce(purchases_last_180days, null) / coalesce(purchases_last_365days, null) 
      ELSE null end as purchase_ratio180d_365d,
    coalesce(avg_days_between_transactions, null) as avg_days_between_transactions,
    coalesce(recency_ratio_score, null) as recency_ratio_score,
    coalesce(total_purchases, null) as total_purchases,
    coalesce(purchases_0_30d_before_last, null) as purchases_0_30d_before_last,
    coalesce(purchases_30_90d_before_last, null) as purchases_30_90d_before_last,
    coalesce(purchases_90_180d_before_last, null) as purchases_90_180d_before_last,
    coalesce(purchases_180_365d_before_last, null) as purchases_180_365d_before_last
    
from base_1
left join transactions_attributes ON base_1.${unification_id} = transactions_attributes.${unification_id}
left join preferred_season_attributes ON base_1.${unification_id} = preferred_season_attributes.${unification_id}
left join purchase_average ON base_1.${unification_id} = purchase_average.${unification_id}
left join last_purchase_attributes on base_1.${unification_id} = last_purchase_attributes.${unification_id};
