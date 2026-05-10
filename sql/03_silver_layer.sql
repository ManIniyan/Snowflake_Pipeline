-- Create the cleaned table with proper data types
USE SCHEMA MEDALLION_DB.SILVER;
CREATE TABLE IF NOT EXISTS CLEAN_SALES (
    ORDER_ID        INTEGER,
    CUSTOMER_NAME   VARCHAR(200),
    PRODUCT         VARCHAR(200),
    QUANTITY        INTEGER,
    UNIT_PRICE      DECIMAL(10,2),
    ORDER_DATE      DATE,
    REGION          VARCHAR(100),
    TOTAL_AMOUNT    DECIMAL(12,2),    -- calculated: quantity * unit_price
    PROCESSED_AT    TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
-- Transform and load from Bronze to Silver-- This query: removes duplicates, removes NULLs, casts types, calculates total
INSERT INTO MEDALLION_DB.SILVER.CLEAN_SALES
    (ORDER_ID, CUSTOMER_NAME, PRODUCT, QUANTITY,
     UNIT_PRICE, ORDER_DATE, REGION, TOTAL_AMOUNT)
WITH deduplicated AS (
    -- Step 1: Remove duplicates using ROW_NUMBER window function
    -- For each ORDER_ID, keep only the first occurrence
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID
            ORDER BY LOADED_AT
        ) AS row_num
    FROM MEDALLION_DB.BRONZE.RAW_SALES
    WHERE CUSTOMER_NAME IS NOT NULL     -- Step 2: Remove rows with NULL customer
      AND ORDER_ID IS NOT NULL
)
SELECT
    ORDER_ID::INTEGER,                  -- cast VARCHAR to INTEGER
    CUSTOMER_NAME,
    PRODUCT,
    QUANTITY::INTEGER,
    UNIT_PRICE::DECIMAL(10,2),
    ORDER_DATE::DATE,                   -- cast VARCHAR to proper DATE
    REGION,x
    (QUANTITY::INTEGER * UNIT_PRICE::DECIMAL(10,2)) AS TOTAL_AMOUNT  -- calculate
FROM deduplicated
WHERE row_num = 1;               

-- keep only first occurrence of each ORDER_ID-- Verify: should have 8 rows (10 minus 1 duplicate, minus 1 NULL customer)
SELECT * FROM MEDALLION_DB.SILVER.CLEAN_SALES;
SELECT COUNT(*) FROM MEDALLION_DB.SILVER.CLEAN_SALES;
