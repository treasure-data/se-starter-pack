with t1 as (
  select distinct
  retail_unification_id,
  CASE
    WHEN regexp_like(${column}, '${sankey.register.pattern}') THEN '${sankey.register.stage}'
    WHEN regexp_like(${column}, '${sankey.login.pattern}') THEN '${sankey.login.stage}'
    WHEN regexp_like(${column}, '${sankey.products.pattern}') THEN '${sankey.products.stage}'
    WHEN regexp_like(${column}, '${sankey.wishlist.pattern}') THEN '${sankey.wishlist.stage}'
    WHEN regexp_like(${column}, '${sankey.cart.pattern}') THEN '${sankey.cart.stage}'
    WHEN regexp_like(${column}, '${sankey.checkout.pattern}') THEN '${sankey.checkout.stage}'
    WHEN regexp_like(${column}, '${sankey.loyalty.pattern}') THEN '${sankey.loyalty.stage}'
    WHEN regexp_like(${column}, '${sankey.return.pattern}') THEN '${sankey.return.stage}'
    WHEN regexp_like(${column}, '${sankey.review.pattern}') THEN '${sankey.review.stage}'
    WHEN regexp_like(${column}, '${sankey.support.pattern}') THEN '${sankey.support.stage}'
    ELSE null
  END AS stage,
  CASE
    WHEN regexp_like(${column}, '${sankey.register.pattern}') THEN cast ('${sankey.register.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.login.pattern}') THEN cast ('${sankey.login.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.products.pattern}') THEN cast ('${sankey.products.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.wishlist.pattern}') THEN cast ('${sankey.wishlist.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.cart.pattern}') THEN cast ('${sankey.cart.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.checkout.pattern}') THEN cast ('${sankey.checkout.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.loyalty.pattern}') THEN cast ('${sankey.loyalty.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.return.pattern}') THEN cast ('${sankey.return.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.review.pattern}') THEN cast ('${sankey.review.indexno}' as int)
    WHEN regexp_like(${column}, '${sankey.support.pattern}') THEN cast ('${sankey.support.indexno}' as int)
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