--TIME TRAVEL just for DATA TESTING 

-- First, check current row count
SELECT COUNT(*) FROM MEDALLION_DB.SILVER.CLEAN_SALES;


-- Simulate a mistake -- delete all rows
DELETE FROM MEDALLION_DB.SILVER.CLEAN_SALES;


SELECT COUNT(*) FROM MEDALLION_DB.SILVER.CLEAN_SALES;
-- Result: 0 rows
-- RECOVER using Time Travel -- query data as it was 5 minutes ago
SELECT * FROM MEDALLION_DB.SILVER.CLEAN_SALES
 AT (OFFSET => -60 * 5); -- 5 minutes ago in seconds
-- Restore: Insert the recovered data back into the table
INSERT INTO MEDALLION_DB.SILVER.CLEAN_SALES
SELECT * FROM MEDALLION_DB.SILVER.CLEAN_SALES
 AT (OFFSET => -60 * 5);
-- Verify recovery
SELECT COUNT(*) FROM MEDALLION_DB.SILVER.CLEAN_SALES;
-- Result: 8 rows -- fully recovered!
