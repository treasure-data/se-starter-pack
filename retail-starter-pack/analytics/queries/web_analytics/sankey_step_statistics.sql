with step_statistics as (
  select "from", "to", from_num, to_num, count(1) as "value"
  from  web_conversion
  where to_num is not null
  group by "from", "to", from_num, to_num
)
select * from step_statistics