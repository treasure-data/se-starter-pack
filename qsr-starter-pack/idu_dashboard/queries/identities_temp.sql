
SELECT '${td.each.col}' as column_name
    ,COALESCE(${td.each.col},0) as count
    ,0 as dedup
    ,${td.each.index} as index
    
FROM ${reporting_db}.${source_tbl}
WHERE COALESCE(${td.each.col},0) > 0