-- SELECT *,
--   CASE
--     WHEN regexp_like('${register.event}', '${column}') THEN '${register.description}'
--     WHEN regexp_like('${login.event}', '${column}') THEN '${login.description}'
--     WHEN regexp_like('${products.event}', '${column}') THEN '${products.description}'
--     WHEN regexp_like('${wishlist.event}', '${column}') THEN '${wishlist.description}'
--     WHEN regexp_like('${cart.event}', '${column}')THEN '${cart.description}'
--     WHEN regexp_like('${checkout.event}', '${column}') THEN '${checkout.description}'
--     WHEN regexp_like('${loyalty.event}', '${column}') THEN '${loyalty.description}'
--     WHEN regexp_like('${return.event}', '${column}') THEN '${return.description}'
--     WHEN regexp_like('${review.event}', '${column}') THEN '${review.description}'
--     WHEN regexp_like('${support.event}', '${column}') THEN '${support.description}'
--     ELSE null
--   END AS touchpoints
-- FROM ${tblname};

with t1 as (
  select distinct
  retail_unification_id,
  CONCAT('Pageviews - ', td_title) as activity_orig,
  time,
  0 as conversion
  -- CASE
  --       WHEN regexp_like('${register.event}', '${column}') THEN '${register.description}'
  --       WHEN regexp_like('${login.event}', '${column}') THEN '${login.description}'
  --       WHEN regexp_like('${products.event}', '${column}') THEN '${products.description}'
  --       WHEN regexp_like('${wishlist.event}', '${column}') THEN '${wishlist.description}'
  --       WHEN regexp_like('${cart.event}', '${column}')THEN '${cart.description}'
  --       WHEN regexp_like('${checkout.event}', '${column}') THEN '${checkout.description}'
  --       WHEN regexp_like('${loyalty.event}', '${column}') THEN '${loyalty.description}'
  --       WHEN regexp_like('${return.event}', '${column}') THEN '${return.description}'
  --       WHEN regexp_like('${review.event}', '${column}') THEN '${review.description}'
  --       WHEN regexp_like('${support.event}', '${column}') THEN '${support.description}'
  --       ELSE 'others'
  -- END AS activity
    -- CASE
  --       WHEN regexp_like('${analytics.dashboards.sankey.register.event}', ${column}) THEN '${analytics.dashboards.sankey.register.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.login.event}', ${column}) THEN '${analytics.dashboards.sankey.login.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.products.event}', ${column}) THEN '${analytics.dashboards.sankey.products.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.wishlist.event}', ${column}) THEN '${analytics.dashboards.sankey.wishlist.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.cart.event}', ${column})THEN '${analytics.dashboards.sankey.cart.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.checkout.event}', ${column}) THEN '${analytics.dashboards.sankey.checkout.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.loyalty.event}', ${column}) THEN '${analytics.dashboards.sankey.loyalty.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.return.event}', ${column}) THEN '${analytics.dashboards.sankey.return.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.review.event}', ${column}) THEN '${analytics.dashboards.sankey.review.description}'
  --       WHEN regexp_like('${analytics.dashboards.sankey.support.event}', ${column}) THEN '${analytics.dashboards.sankey.support.description}'
  --       ELSE 'others'
  -- END AS activity
  from ${tblname}
),
t2 as (
    select *, ROW_NUMBER() OVER(PARTITION by retail_unification_id, grp order by time) as row_num
    from (
        select t1.*, CAST(FROM_UNIXTIME(time) as VARCHAR) as timestamp, sum(conversion) over(partition by retail_unification_id order by time) as grp
        from t1
    )
    order by retail_unification_id, time asc
)
select * from t2