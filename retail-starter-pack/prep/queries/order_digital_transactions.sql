DROP TABLE IF EXISTS ${prp}_${sub}.order_digital_transactions;

CREATE TABLE ${prp}_${sub}.order_digital_transactions

select * from ${raw}_${sub}.order_digital_transactions
