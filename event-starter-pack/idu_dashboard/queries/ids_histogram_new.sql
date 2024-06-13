SELECT    element_at(b,1) AS num_times, cast(element_at(b,2) AS integer) AS ids, id_context, id_type
FROM    (
          SELECT  split(value,':') AS b, id_context, id_type
          FROM    ${prefix}ids_histogram_temp
          CROSS JOIN UNNEST (${prefix}ids_histogram_temp.hist) AS t (value)
          
)