-- Staging: raw files becomes staging table
CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE TABLE staging.customers
AS
SELECT DISTINCT
    customer_id:: INT as customer_id,
    TRIM(name) AS name,
    NULLIF(TRIM(email), '') AS email,
    UPPER(TRIM(city)[1]) || LOWER(TRIM(city)[2:]) AS city,
    signup_date::DATE AS signup_date
FROM read_csv('data/raw/customers.csv', header=true, all_varchar=true);

CREATE OR REPLACE TABLE staging.products
AS
SELECT sku, name, category, price::DECIMAL(10, 2) AS price
FROM read_json('data/raw/products.json');

CREATE OR REPLACE TABLE staging.orders
AS
SELECT
     order_id, 
     customer_id, 
     ordered_at::TIMESTAMP ordered_at, 
     status,
     items,
     dt
FROM read_json('data/raw/orders/*/orders.jsonl', hive_partitioning=true);

SELECT 
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM staging.customers
UNION ALL
SELECT
    'products',
    COUNT(*)
FROM staging.products
UNION ALL
SELECT 
    'orders',
    COUNT(*)
FROM staging.orders;
