with lbl as (
  select '${analytics.dashboards.sankey.register.stage}' as label, cast('${analytics.dashboards.sankey.register.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.login.stage}' as label, cast('${analytics.dashboards.sankey.login.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.products.stage}' as label, cast('${analytics.dashboards.sankey.products.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.wishlist.stage}' as label, cast('${analytics.dashboards.sankey.wishlist.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.cart.stage}' as label, cast('${analytics.dashboards.sankey.cart.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.checkout.stage}' as label, cast('${analytics.dashboards.sankey.checkout.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.loyalty.stage}' as label, cast('${analytics.dashboards.sankey.loyalty.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.return.stage}' as label, cast('${analytics.dashboards.sankey.return.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.review.stage}' as label, cast('${analytics.dashboards.sankey.review.indexno}' as int) as row_num
  union
  select '${analytics.dashboards.sankey.support.stage}' as label, cast('${analytics.dashboards.sankey.support.indexno}' as int) as row_num
)
select label, row_num
from lbl
order by row_num