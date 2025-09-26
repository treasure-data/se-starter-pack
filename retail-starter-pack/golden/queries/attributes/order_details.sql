with order_details_cte as (
select 
  ${unification_id},
  trfmd_product_department
from 
  order_details
),
 raw_attr as (
select 
  ${unification_id},
  COUNT(distinct trfmd_product_department) as distinct_count_product_departments, 
array_join(ARRAY_AGG(DISTINCT trfmd_product_department ORDER BY trfmd_product_department) 
    FILTER (WHERE trfmd_product_department IS NOT NULL), ', ') as distinct_product_departments_string,
ARRAY_AGG(DISTINCT trfmd_product_department ORDER BY trfmd_product_department) 
    FILTER (WHERE trfmd_product_department IS NOT NULL) as distinct_product_departments
from 
  order_details_cte
GROUP BY 1
), 

top_product_combos as (
  select 
    distinct_product_departments_string
  from 
  raw_attr
  group by 1
  order by count(*) desc
  limit 20
)

select * from 
raw_attr where distinct_product_departments_string in (select distinct_product_departments_string from top_product_combos)