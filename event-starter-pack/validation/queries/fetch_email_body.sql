WITH concatenated AS (
    SELECT array_agg(html_content ORDER BY rownum) AS html_array
    FROM email_content
)
SELECT array_join(html_array, '') AS html_content
FROM concatenated;
