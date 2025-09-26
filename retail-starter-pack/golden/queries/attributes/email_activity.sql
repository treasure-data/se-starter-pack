-- Email engagement metrics before last purchase date
WITH

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
-- Email data with activity details
email_cte AS (
    SELECT
        trfmd_activity_date_unix,
        EXP(-0.693 * ((to_unixtime(current_timestamp) - trfmd_activity_date_unix) / 86400.0) / 45.0) as recency_weight,
        ${unification_id},
        trfmd_activity_type as activity_type
    FROM email_activity
),

-- Standard email attributes (your existing logic)
email_attributes AS (
    SELECT
        ${unification_id},
        MAX(
            CASE 
                WHEN lower(activity_type) LIKE '%sent%' OR lower(activity_type) LIKE '%send%' 
                THEN trfmd_activity_date_unix 
                ELSE NULL 
            END
        ) AS last_email_send_date_unix,
        
        SUM(
            CASE
                -- High value: clicks (weight = 3)
                WHEN activity_type LIKE '%click%' THEN 3.0 * recency_weight
                -- Medium value: opens (weight = 2)
                WHEN activity_type LIKE '%open%' THEN 2.0 * recency_weight
                -- Negative: unsubscribes and bounces
                WHEN activity_type LIKE '%unsub%' THEN -5.0 * recency_weight
                ELSE 0.0
            END
        ) AS email_engagement_score,
        
        CASE 
            WHEN COUNT(CASE WHEN lower(activity_type) LIKE '%hardbounce%' THEN activity_type ELSE NULL END) > 0 
            THEN 'True' 
            ELSE 'False' 
        END AS email_hardbounce
    FROM email_cte
    GROUP BY ${unification_id}
),

last_purchase_cte as (
    SELECT
      ${unification_id},
      max(CASE WHEN trfmd_order_datetime_unix is not null THEN trfmd_order_datetime_unix ELSE NULL END) AS last_purchase_date_unix
      FROM
  transactions_cte
  group by 
  ${unification_id}
),

-- Email metrics before last purchase (similar to transaction logic)
email_before_purchase_metrics AS (
    SELECT 
        e.${unification_id},
        
        -- Emails sent 0-30 days before last purchase
        COUNT(DISTINCT 
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 30 * 86400)
                AND e.trfmd_activity_date_unix <= lp.last_purchase_date_unix
                AND (lower(e.activity_type) LIKE '%sent%' OR lower(e.activity_type) LIKE '%send%')
                THEN e.trfmd_activity_date_unix 
            END
        ) AS emails_sent_0_30d_before_last,
        
        -- Emails sent 30-90 days before last purchase
        COUNT(DISTINCT 
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 90 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 30 * 86400)
                AND (lower(e.activity_type) LIKE '%sent%' OR lower(e.activity_type) LIKE '%send%')
                THEN e.trfmd_activity_date_unix 
            END
        ) AS emails_sent_30_90d_before_last,
        
        -- Emails sent 90-180 days before last purchase
        COUNT(DISTINCT 
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 180 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 90 * 86400)
                AND (lower(e.activity_type) LIKE '%sent%' OR lower(e.activity_type) LIKE '%send%')
                THEN e.trfmd_activity_date_unix 
            END
        ) AS emails_sent_90_180d_before_last,
        
        -- Emails sent 180-365 days before last purchase
        COUNT(DISTINCT 
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 365 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 180 * 86400)
                AND (lower(e.activity_type) LIKE '%sent%' OR lower(e.activity_type) LIKE '%send%')
                THEN e.trfmd_activity_date_unix 
            END
        ) AS emails_sent_180_365d_before_last,
        
        -- Opens 0-30 days before last purchase
        COUNT(
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 30 * 86400)
                AND e.trfmd_activity_date_unix <= lp.last_purchase_date_unix
                AND lower(e.activity_type) LIKE '%open%'
                THEN 1
            END
        ) AS opens_0_30d_before_last,
        
        -- Opens 30-90 days before last purchase
        COUNT(
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 90 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 30 * 86400)
                AND lower(e.activity_type) LIKE '%open%'
                THEN 1
            END
        ) AS opens_30_90d_before_last,
        
        -- Clicks 0-30 days before last purchase
        COUNT(
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 30 * 86400)
                AND e.trfmd_activity_date_unix <= lp.last_purchase_date_unix
                AND lower(e.activity_type) LIKE '%click%'
                THEN 1
            END
        ) AS clicks_0_30d_before_last,
        
        -- Clicks 30-90 days before last purchase
        COUNT(
            CASE 
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 90 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 30 * 86400)
                AND lower(e.activity_type) LIKE '%click%'
                THEN 1
            END
        ) AS clicks_30_90d_before_last,
        
        -- Engagement score 0-30 days before last purchase
        SUM(
            CASE
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 30 * 86400)
                AND e.trfmd_activity_date_unix <= lp.last_purchase_date_unix
                THEN 
                    CASE
                        WHEN e.activity_type LIKE '%click%' THEN 3.0
                        WHEN e.activity_type LIKE '%open%' THEN 2.0
                        WHEN e.activity_type LIKE '%unsub%' THEN -5.0
                        ELSE 0.0
                    END
                ELSE 0
            END
        ) AS engagement_score_0_30d_before_last,
        
        -- Engagement score 30-90 days before last purchase
        SUM(
            CASE
                WHEN e.trfmd_activity_date_unix > (lp.last_purchase_date_unix - 90 * 86400)
                AND e.trfmd_activity_date_unix <= (lp.last_purchase_date_unix - 30 * 86400)
                THEN 
                    CASE
                        WHEN e.activity_type LIKE '%click%' THEN 3.0
                        WHEN e.activity_type LIKE '%open%' THEN 2.0
                        WHEN e.activity_type LIKE '%unsub%' THEN -5.0
                        ELSE 0.0
                    END
                ELSE 0
            END
        ) AS engagement_score_30_90d_before_last
        
    FROM email_cte e
    INNER JOIN last_purchase_cte lp ON e.${unification_id} = lp.${unification_id}
    GROUP BY e.${unification_id}
)

-- Final output combining all metrics
SELECT 
    COALESCE(ea.${unification_id}, ebp.${unification_id}) AS ${unification_id},
    ea.last_email_send_date_unix,
    ea.email_engagement_score,
    ea.email_hardbounce,
    
    -- Email metrics before last purchase
    -- COALESCE(ebp.emails_sent_0_30d_before_last, 0) AS emails_sent_0_30d_before_last,
    -- COALESCE(ebp.emails_sent_30_90d_before_last, 0) AS emails_sent_30_90d_before_last,
    -- COALESCE(ebp.emails_sent_90_180d_before_last, 0) AS emails_sent_90_180d_before_last,
    -- COALESCE(ebp.emails_sent_180_365d_before_last, 0) AS emails_sent_180_365d_before_last,
    
    -- COALESCE(ebp.opens_0_30d_before_last, 0) AS opens_0_30d_before_last,
    -- COALESCE(ebp.opens_30_90d_before_last, 0) AS opens_30_90d_before_last,
    
    -- COALESCE(ebp.clicks_0_30d_before_last, 0) AS clicks_0_30d_before_last,
    -- COALESCE(ebp.clicks_30_90d_before_last, 0) AS clicks_30_90d_before_last,
    
    COALESCE(ebp.engagement_score_0_30d_before_last, 0) AS engagement_score_0_30d_before_last,
    COALESCE(ebp.engagement_score_30_90d_before_last, 0) AS engagement_score_30_90d_before_last
    
    -- Calculate open rates before last purchase
    -- CASE 
    --     WHEN ebp.emails_sent_0_30d_before_last > 0 
    --     THEN CAST(ebp.opens_0_30d_before_last AS DOUBLE) / ebp.emails_sent_0_30d_before_last
    --     ELSE NULL 
    -- END AS open_rate_0_30d_before_last,
    
    -- CASE 
    --     WHEN ebp.emails_sent_30_90d_before_last > 0 
    --     THEN CAST(ebp.opens_30_90d_before_last AS DOUBLE) / ebp.emails_sent_30_90d_before_last
    --     ELSE NULL 
    -- END AS open_rate_30_90d_before_last,
    
    -- -- Calculate click rates before last purchase
    -- CASE 
    --     WHEN ebp.emails_sent_0_30d_before_last > 0 
    --     THEN CAST(ebp.clicks_0_30d_before_last AS DOUBLE) / ebp.emails_sent_0_30d_before_last
    --     ELSE NULL 
    -- END AS click_rate_0_30d_before_last,
    
    -- CASE 
    --     WHEN ebp.emails_sent_30_90d_before_last > 0 
    --     THEN CAST(ebp.clicks_30_90d_before_last AS DOUBLE) / ebp.emails_sent_30_90d_before_last
    --     ELSE NULL 
    -- END AS click_rate_30_90d_before_last
    
FROM email_attributes ea
LEFT JOIN email_before_purchase_metrics ebp ON ea.${unification_id} = ebp.${unification_id};