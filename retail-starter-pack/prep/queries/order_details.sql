DROP TABLE IF EXISTS ${prp}_${sub}.order_details;

CREATE TABLE ${prp}_${sub}.order_details

select * from ${raw}_${sub}.order_details
