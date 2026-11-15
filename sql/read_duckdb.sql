SELECT
    order_date, 
    COUNT(*) AS lines,
    SUM(amount) AS revenue
FROM read_parquet('data/lake/silver/order_lines/*/*.parquet', hive_partitioning=true)
GROUP BY 1
ORDER BY 1;