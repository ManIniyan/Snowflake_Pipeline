-- AUTOMATION USING STREAMS AND TASKS --

-- STREAM: Create a stream on the Bronze table to track new records
USE SCHEMA MEDALLION_DB.BRONZE;
CREATE STREAM IF NOT EXISTS SALES_STREAM
    ON TABLE MEDALLION_DB.BRONZE.RAW_SALES
    COMMENT = 'Captures all new records inserted into RAW_SALES';

-- Check the stream (will be empty until new data arrives)
SELECT * FROM SALES_STREAM;
-- TASK: Create a task that runs every hour-- It reads new records from the Stream and loads them into Silver
USE SCHEMA MEDALLION_DB.SILVER;
CREATE TASK IF NOT EXISTS BRONZE_TO_SILVER_TASK
    WAREHOUSE = MEDALLION_WH
    SCHEDULE = 'USING CRON 0 * * * * UTC'   -- every hour at minute 0
    COMMENT = 'Incremental load from Bronze Stream to Silver'
AS
INSERT INTO MEDALLION_DB.SILVER.CLEAN_SALES
    (ORDER_ID, CUSTOMER_NAME, PRODUCT, QUANTITY,
     UNIT_PRICE, ORDER_DATE, REGION, TOTAL_AMOUNT)
SELECT
    ORDER_ID::INTEGER,
    CUSTOMER_NAME,
    PRODUCT,
    QUANTITY::INTEGER,
    UNIT_PRICE::DECIMAL(10,2),
    ORDER_DATE::DATE,
    REGION,
    (QUANTITY::INTEGER * UNIT_PRICE::DECIMAL(10,2))
FROM MEDALLION_DB.BRONZE.SALES_STREAM
WHERE METADATA$ACTION = 'INSERT'         -- only process new inserts
  AND CUSTOMER_NAME IS NOT NULL;


  -- Tasks are created in SUSPENDED state. Resume the task to activate it:
ALTER TASK BRONZE_TO_SILVER_TASK SUSPEND;

-- To manually trigger the task (for testing):
EXECUTE TASK BRONZE_TO_SILVER_TASK;

-- Check task run history:
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'BRONZE_TO_SILVER_TASK'
)) ORDER BY SCHEDULED_TIME DESC;    
