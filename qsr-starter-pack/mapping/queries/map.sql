WITH json_data AS (
    SELECT 
        json_parse('${tbl.columns}') AS data
), 

select * from json_data