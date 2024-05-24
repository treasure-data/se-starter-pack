select * from
(
  select null as label, t1.value, t2.row_num as from_num, t3.row_num as to_num, stage
  from  web_conversion_step_statistics t1
  left join
  web_conversion_labels t2
  on t1."from" = t2.label
  left join
  web_conversion_labels t3
  on t1.to = t3.label
)
union all
select CONCAT(LPAD(CAST(row_num as VARCHAR), 3, '0'), ':', label), NULL as value, NULL as from_num, NULL as to_num, NULL AS stage
from web_conversion_labels