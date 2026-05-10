USE SCHEMA MEDALLION_DB.GOLD;
CREATE TABLE IF NOT EXISTS DAILY_SALES_SUMMARY AS
SELECT
    ORDER_DATE,
    REGION,
    COUNT(ORDER_ID)             AS total_orders,
    SUM(QUANTITY)               AS total_units_sold,
    SUM(TOTAL_AMOUNT)           AS total_revenue,
    AVG(TOTAL_AMOUNT)           AS avg_order_value,
    MAX(TOTAL_AMOUNT)           AS max_order_value
FROM MEDALLION_DB.SILVER.CLEAN_SALES
GROUP BY ORDER_DATE, REGION
ORDER BY ORDER_DATE, REGION;

-- Gold table 2: Customer-level summary
CREATE TABLE IF NOT EXISTS CUSTOMER_SUMMARY AS
SELECT
    CUSTOMER_NAME,
    COUNT(ORDER_ID)             AS total_orders,
    SUM(TOTAL_AMOUNT)           AS lifetime_value,
    MIN(ORDER_DATE)             AS first_order_date,
    MAX(ORDER_DATE)             AS last_order_date
FROM MEDALLION_DB.SILVER.CLEAN_SALES
GROUP BY CUSTOMER_NAME
ORDER BY lifetime_value DESC;

-- Verify
SELECT * FROM DAILY_SALES_SUMMARY;
SELECT * FROM CUSTOMER_SUMMARY;
