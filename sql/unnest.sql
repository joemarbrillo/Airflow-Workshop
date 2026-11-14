SELECT 
    i.qty,
    COUNT(*) AS lines
FROM (
    SELECT unnest(items) AS i FROM staging.orders)
GROUP BY ALL ORDER BY 1;
