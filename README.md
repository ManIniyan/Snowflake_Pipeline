# Snowflake Medallion Architecture Pipeline

## What This Project Does
An end-to-end ELT data pipeline built on Snowflake implementing 
the Medallion Architecture pattern (Bronze → Silver → Gold).

## Architecture
Raw CSV Data (S3/Stage)
       ↓
  BRONZE Layer  → Raw data loaded as-is using COPY INTO
       ↓
  SILVER Layer  → Cleaned, deduplicated, type-cast data
       ↓
  GOLD Layer    → Analytics-ready aggregated summary tables

## Tech Stack
- Snowflake Data Warehouse
- COPY INTO (batch ingestion)
- Snowflake Streams & Tasks (incremental CDC)
- RBAC (role-based access control)
- Time Travel (data recovery)
- AWS S3 External Stage (architecture pattern)

## Project Structure
sql/01_setup_environment.sql  → Database, schema, warehouse setup
sql/02_bronze_layer.sql       → Raw ingestion layer
sql/03_silver_layer.sql       → Cleaning and transformation
sql/04_gold_layer.sql         → Analytics summary tables
sql/05_streams_and_tasks.sql  → Automated incremental processing
sql/06_rbac.sql               → Access control by layer
sql/07_time_travel.sql        → Data recovery testing

## Key Concepts Implemented
- Medallion Architecture (Bronze/Silver/Gold)
- SCD Type 2 pattern awareness
- Incremental ELT using Streams & Tasks
- Data governance via RBAC
- ROW_NUMBER deduplication
- Type casting and NULL handling
