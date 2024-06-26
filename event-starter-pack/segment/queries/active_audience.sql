with active_audience as (
  select b.file, b.name, b.audience_id, b.url, rank() over (partition by b.file order by b.time desc) rnk
  from ${segment.tables.parent_segment_templates} a 
  inner join automation_parent_segments b 
  on (a.file = b.file)
  where b.audience_id is not null
)
select file, name, audience_id, url
from active_audience where rnk = 1;