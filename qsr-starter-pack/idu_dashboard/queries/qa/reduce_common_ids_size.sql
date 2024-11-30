WITH RankedIDs AS (
  SELECT
T1.*,
    ROW_NUMBER() OVER (PARTITION BY over_merged_id, id_type ORDER BY total_sets DESC) AS rn
  FROM idu_qa_common_ids T1
)
SELECT
*
FROM RankedIDs
WHERE rn <= 10