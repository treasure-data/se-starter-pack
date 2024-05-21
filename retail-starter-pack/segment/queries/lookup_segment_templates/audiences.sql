select a.folder, a.file ,b.name, b.audience_id, b.url
from ${meta}.${segment.tables.segment_templates} a
cross join ${meta}.active_audience b