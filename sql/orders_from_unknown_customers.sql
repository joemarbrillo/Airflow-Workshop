SELECT
    COUNT(*) AS orders
FROM staging.orders o
WHERE NOT EXISTS (
    SELECT 1 FROM staging.customers c WHERE c.customer_id = o.customer_id
    );