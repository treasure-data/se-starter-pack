select a.folder, a.file ,b.name, b.audience_id, b.url
from va_config_${sub}.${segment.tables.segment_templates} a
cross join va_config_${sub}.active_audience b