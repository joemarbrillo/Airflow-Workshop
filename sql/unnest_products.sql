SELECT 
    i.sku,
    COUNT(*) AS lines
FROM (
    SELECT unnest(items) AS i FROM staging.orders
    )
LEFT JOIN staging.products p
ON p.sku = i.sku
WHERE p.sku IS NULL
GROUP BY ALL;