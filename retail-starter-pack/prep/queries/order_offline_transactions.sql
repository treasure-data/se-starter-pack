DROP TABLE IF EXISTS ${prp}_${sub}.order_offline_transactions;

CREATE TABLE ${prp}_${sub}.order_offline_transactions

select * from ${raw}_${sub}.order_offline_transactions
