drop table if exists sales_market_basket_analysis; 

create table if not exists sales_market_basket_analysis (
   product1 varchar,
   product2 varchar,
   order_count bigint,
   support double,
   confidence_atob double,
   confidence_btoa double,
   lift double
);