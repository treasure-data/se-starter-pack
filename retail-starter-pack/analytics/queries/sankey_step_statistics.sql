
with t1 as (
    SELECT
    stage,
    CASE
        WHEN CARDINALITY(touches) = 2 THEN touches
        ELSE touches || 'Conversion'
    END AS touches,
    count(*) as value
    FROM (
            SELECT
            CASE WHEN grp = 0 THEN 'First'
            ELSE 'Repurchase'
            END AS stage,
            ARRAY_AGG(activity_orig order by time) as touches
            from web_conversion
            where (row_num in (${range.from},${range.from+1}) and grp = 0) or (row_num in (${range.from+1},${range.from+2}) and grp > 0)
            group by retail_unification_id, grp
        )
    group by 1,2 order by 2 desc
)
SELECT * FROM
(
  SELECT
    stage,
    CONCAT('Step ${range.from} - ', touches[1]) as "from",
    CASE
    WHEN touches[2] = 'Conversion' THEN touches[2]
    ELSE CONCAT('Step ${range.from+1} - ', touches[2])
    END AS "to",
    value
    from t1
    where stage = 'First'
    and  value > (
        SELECT MAX(value) * 0.2
        FROM t1
        where stage = 'First'
    )
    order by value desc
    limit 10
)
UNION ALL
(
  SELECT
    stage,
    CONCAT('Step ${range.from} - ', touches[1]) as "from",
    CASE
    WHEN touches[2] = 'Conversion' THEN touches[2]
    ELSE CONCAT('Step ${range.from+1} - ', touches[2])
    END AS "to",
    value
    from t1
    where stage = 'Repurchase'
    and value > (
        SELECT MAX(value) * 0.2
        FROM t1
        where stage = 'Repurchase'
    )
    order by value desc
    limit 10
)