SELECT
    details.*,
    COALESCE(
        digital.trfmd_order_datetime_unix,
        offline.trfmd_order_datetime_unix
    ) as trfmd_order_datetime_unix
FROM
    order_details details
    left join order_digital_transactions digital on details.order_no = digital.order_no
    left join order_offline_transactions offline on details.order_no = offline.order_no