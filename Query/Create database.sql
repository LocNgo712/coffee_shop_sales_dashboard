#DROP DATABASE IF EXISTS coffee_shop_sales_db;
#CREATE DATABASE coffee_shop_sales_db;
#SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
USE coffee_shop_sales_db;

SELECT *FROM coffee_shop_sales;

DESCRIBE coffee_shop_sales;

#Change datatype of transaction_date and transaction_time

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;