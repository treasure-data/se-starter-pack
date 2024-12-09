with lbl as (
  select '${sankey.register.stage}' as label, cast('${sankey.register.indexno}' as int) as row_num
  union
  select '${sankey.login.stage}' as label, cast('${sankey.login.indexno}' as int) as row_num
  union
  select '${sankey.products.stage}' as label, cast('${sankey.products.indexno}' as int) as row_num
  union
  select '${sankey.wishlist.stage}' as label, cast('${sankey.wishlist.indexno}' as int) as row_num
  union
  select '${sankey.cart.stage}' as label, cast('${sankey.cart.indexno}' as int) as row_num
  union
  select '${sankey.checkout.stage}' as label, cast('${sankey.checkout.indexno}' as int) as row_num
  union
  select '${sankey.loyalty.stage}' as label, cast('${sankey.loyalty.indexno}' as int) as row_num
  union
  select '${sankey.return.stage}' as label, cast('${sankey.return.indexno}' as int) as row_num
  union
  select '${sankey.review.stage}' as label, cast('${sankey.review.indexno}' as int) as row_num
  union
  select '${sankey.support.stage}' as label, cast('${sankey.support.indexno}' as int) as row_num
)
select label, row_num
from lbl
order by row_num