select * from
(
  select null as label, t1.value, t1.from_num as from_num, t1.to_num as to_num, cast(NULL as varchar) as stage from web_conversion_step_statistics t1
  union all
  select CONCAT(LPAD(CAST(row_num as VARCHAR), 3, '0'), ':', label) as label, NULL as value, NULL as from_num, NULL as to_num, cast(NULL as varchar) AS stage
  from web_conversion_labels
)