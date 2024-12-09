-- @TD enable_cartesian_product:true
WITH 
order_details_window as (
    SELECT * FROM order_details where td_interval(trfmd_order_datetime_unix, '-365d')
),

total_orders AS (
    SELECT COUNT(DISTINCT order_no) AS total_count
    FROM order_details_window
),
pair_counts AS (
    SELECT
        a.trfmd_product_name AS product1,
        b.trfmd_product_name AS product2,
        COUNT(DISTINCT a.order_no) AS order_count
    FROM
        order_details_window a
    JOIN
        order_details_window b ON a.order_no = b.order_no AND a.trfmd_product_name < b.trfmd_product_name
    GROUP BY
        a.trfmd_product_name, b.trfmd_product_name
),
product_counts AS (
    SELECT
        trfmd_product_name,
        COUNT(DISTINCT order_no) AS product_count
    FROM
        order_details_window
    GROUP BY
        trfmd_product_name
) 
-- DIGDAG_INSERT_LINE
SELECT
    pc.product1,
    pc.product2,
    pc.order_count,
    CAST(pc.order_count as DOUBLE) / CAST(t.total_count as DOUBLE) AS support,
    CAST(pc.order_count as DOUBLE) / CAST(p1.product_count as DOUBLE) AS confidence_AtoB,
    CAST(pc.order_count as DOUBLE) / CAST(p1.product_count as DOUBLE) AS confidence_BtoA,
    (CAST(pc.order_count as DOUBLE) / CAST(p1.product_count as DOUBLE)) / ( CAST(p2.product_count as DOUBLE) / CAST(t.total_count as DOUBLE)) as lift
FROM
    pair_counts pc
JOIN
    product_counts p1 ON pc.product1 = p1.trfmd_product_name
JOIN
    product_counts p2 ON pc.product2 = p2.trfmd_product_name
CROSS JOIN
    total_orders t
ORDER BY
    order_count DESC
