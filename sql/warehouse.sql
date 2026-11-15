-- Warehouse: a star schema
CREATE SCHEMA IF NOT EXISTS wh;

DROP TABLE IF EXISTS wh.dim_customers;

CREATE OR REPLACE TABLE wh.dim_customer
AS
SELECT 
    row_number() OVER(ORDER BY customer_id) as customer_key,
    *
FROM staging.customers
UNION ALL
SELECT
    0,
    -1,
    'Unknown customer',
    NULL,
    'Unknown',
    NULL;

CREATE OR REPLACE TABLE wh.dim_product
AS
SELECT
    row_number() OVER(ORDER BY sku) AS product_key,
    *
FROM staging.products;

CREATE OR REPLACE TABLE wh.dim_date
AS
SELECT 
    strftime(d, '%Y%m%d')::INTEGER AS date_key,
    d::DATE AS date,
    year(d) AS year,
    month(d) AS month,
    dayname(d) AS dayname,
    isodow(d) >= 6 AS is_weekday
FROM range(DATE '2026-01-01', DATE '2027-01-01', INTERVAL 1 DAY) AS t(d);

CREATE OR REPLACE TABLE wh.fact_sales
AS
SELECT
    d.date_key,
    COALESCE(c.customer_key) AS customer_key,
    p.product_key,
    s.order_id,
    s.status,
    s.qty,
    s.amount::DECIMAL(12, 2) AS amount
FROM read_parquet("data/lake/silver/order_lines/*/*.parquet", hive_partitioning=true) s
JOIN wh.dim_product p ON p.sku = s.sku
LEFT JOIN wh.dim_customer c ON c.customer_id = s.customer_id
JOIN wh.dim_date d ON d.date = s.order_date;

SELECT 'dim_customer' AS table_name,
    COUNT(*) AS row_count
FROM wh.dim_customer
UNION ALL
SELECT 'dim_product',
    COUNT(*)
FROM wh.dim_product
UNION ALL
SELECT 'dim_date',
    COUNT(*)
FROM wh.dim_date
UNION ALL
SELECT 'fact_sales',
    COUNT(*)
FROM wh.fact_sales;

