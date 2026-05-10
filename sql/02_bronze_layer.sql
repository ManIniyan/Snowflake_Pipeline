USE SCHEMA MEDALLION_DB.BRONZE;
-- Create the raw table -- all columns as VARCHAR (raw, no type enforcement yet)

CREATE OR REPLACE TABLE RAW_SALES (
    ORDER_ID        VARCHAR,
    CUSTOMER_NAME   VARCHAR,
    PRODUCT         VARCHAR,
    QUANTITY        VARCHAR,
    UNIT_PRICE      VARCHAR,
    ORDER_DATE      VARCHAR,
    REGION          VARCHAR,
    LOADED_AT       TIMESTAMP DEFAULT CURRENT_TIMESTAMP()  -- when was this record loaded
);

-- Load the CSV file from the stage into the table
COPY INTO RAW_SALES (ORDER_ID, CUSTOMER_NAME, PRODUCT, QUANTITY, UNIT_PRICE, ORDER_DATE, REGION)
FROM @raw_stage
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
)
ON_ERROR = 'CONTINUE';

--Validating that the raw data loaded in our table
SELECT * FROM RAW_SALES
