with t1 as (
  select distinct
  retail_unification_id,
  CASE
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.register.pattern}') THEN '${analytics.dashboards.sankey.register.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.login.pattern}') THEN '${analytics.dashboards.sankey.login.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.products.pattern}') THEN '${analytics.dashboards.sankey.products.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.wishlist.pattern}') THEN '${analytics.dashboards.sankey.wishlist.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.cart.pattern}') THEN '${analytics.dashboards.sankey.cart.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.checkout.pattern}') THEN '${analytics.dashboards.sankey.checkout.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.loyalty.pattern}') THEN '${analytics.dashboards.sankey.loyalty.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.return.pattern}') THEN '${analytics.dashboards.sankey.return.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.review.pattern}') THEN '${analytics.dashboards.sankey.review.stage}'
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.support.pattern}') THEN '${analytics.dashboards.sankey.support.stage}'
    ELSE null
  END AS stage,
  CASE
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.register.pattern}') THEN cast ('${analytics.dashboards.sankey.register.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.login.pattern}') THEN cast ('${analytics.dashboards.sankey.login.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.products.pattern}') THEN cast ('${analytics.dashboards.sankey.products.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.wishlist.pattern}') THEN cast ('${analytics.dashboards.sankey.wishlist.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.cart.pattern}') THEN cast ('${analytics.dashboards.sankey.cart.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.checkout.pattern}') THEN cast ('${analytics.dashboards.sankey.checkout.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.loyalty.pattern}') THEN cast ('${analytics.dashboards.sankey.loyalty.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.return.pattern}') THEN cast ('${analytics.dashboards.sankey.return.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.review.pattern}') THEN cast ('${analytics.dashboards.sankey.review.indexno}' as int)
    WHEN regexp_like(${column}, '${analytics.dashboards.sankey.support.pattern}') THEN cast ('${analytics.dashboards.sankey.support.indexno}' as int)
    ELSE null
  END AS stage_indexno,
  time
  from ${tblname}
),
t2 as (
  select
    retail_unification_id,
    stage,
    stage_indexno,
    time
  from t1
  where (stage is not null or stage_indexno is not null)
),
t3 as (
  select
    retail_unification_id,
    stage as "from",
    LEAD(stage, 1) OVER (PARTITION BY retail_unification_id ORDER BY time) AS "to",
    stage_indexno from_num,
    LEAD(stage_indexno, 1) OVER (PARTITION BY retail_unification_id ORDER BY time) AS to_num,
    time
  from t2
  order by retail_unification_id, time
)
select *
from t3
where to_num > from_num
order by retail_unification_id, time