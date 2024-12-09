
SELECT s.total_distinct as profiles_before_unification
    ,${td.each.sum_addressable}+${td.each.sum_non_addressable} as total_source_ids
    ,0 as distinct_source_ids
    ,${td.each.sum_addressable} as reach
    ,${td.each.sum_addressable} as addresable_id_non_unique
    ,${td.each.sum_non_addressable} as non_addressable_ids
    ,${td.each.sum_known} as known_ids
    ,${td.each.sum_unknown} as unknown_ids
    ,${td.each.sum_composite} as composite_ids
    ,ROUND((s.total_distinct - r.canonical_ids)/(s.total_distinct*1.0),3) as overall_deduplication_rate
    ,r.canonical_ids as canonical_ids
    ,1 as join_key
    ,0 as index
FROM ${reporting_db}.${source_tbl} s
CROSS JOIN (
    SELECT a.total_distinct as canonical_ids
    FROM ${reporting_db}.${result_tbl} a
    WHERE a.from_table = '*'
    ) r
WHERE s.from_table = '*'
