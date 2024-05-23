
  select "from" as label, ROW_NUMBER() OVER() - 1 as row_num from
  (
    select "from" from web_conversion_step_statistics
    union
    select "to" from web_conversion_step_statistics
  )