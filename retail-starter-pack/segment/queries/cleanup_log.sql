drop table if exists _audience_tmp_;

create table if not exists _audience_tmp_ as
with audience as (
  select b.*, rank() over (partition by b.file order by b.time desc) rnk
  from automation_parent_segments b 
  where b.audience_id is not null
)
select time
, file
, audience_id
, name
, status
, created_time
, url 
from audience 
where rnk = 1;

-- delete from automation_parent_segments aps
-- where NOT EXISTS (
--   select 1
--   from _audience_tmp_ a
--   where a.file = aps.file
--     and a.audience_id = aps.audience_id
--     and a.time = aps.time
--     and a.rnk = 1
-- );

drop table if exists automation_parent_segments;

alter table if exists  _audience_tmp_ rename to  automation_parent_segments;