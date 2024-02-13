-- Query public available table
SELECT station_id, name FROM
    bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;


-- SETUP

-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://nyctaxi-zoomcamp-davidrd123/green_taxi_2022/green_tripdata_2022-*.parquet']
);

-- Creating a BQ table (not partitioned or clustered)
CREATE OR REPLACE TABLE de-zoomcamp-davidrd123.ny_taxi.green_tripdata_non_partitioned AS
SELECT * FROM de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata;
--------------------

-- Look at the data
SELECT * FROM `de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata` limit 10;
SELECT * FROM `de-zoomcamp-davidrd123.ny_taxi.green_tripdata_non_partitioned` limit 10;

-- HW Question 1
-- What is count of records for the 2022 Green Taxi Data??

SELECT COUNT(*) from `de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata`;

-- HW Question 2
--- Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables

SELECT COUNT(DISTINCT(PULocationID)) FROM de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata;

-- Count distinct PULocationID from the materialized (non-partitioned) table
SELECT COUNT(DISTINCT PULocationID) FROM `de-zoomcamp-davidrd123.ny_taxi.green_tripdata_non_partitioned`;

-- HW Question 3
--- How many records have a fare_amount of 0?
SELECT COUNT(*) FROM de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata
WHERE fare_amount = 0;


-- HW Question 4
--- What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)

CREATE OR REPLACE TABLE de-zoomcamp-davidrd123.ny_taxi.green_tripdata_partitioned_clustered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT *
FROM de-zoomcamp-davidrd123.ny_taxi.external_green_tripdata;

-- HW Question 5
--- Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)
SELECT COUNT(DISTINCT PULocationID) as pu_loc_count
FROM de-zoomcamp-davidrd123.ny_taxi.green_tripdata_non_partitioned
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

SELECT COUNT(DISTINCT PULocationID) as pu_loc_count
FROM de-zoomcamp-davidrd123.`ny_taxi.green_tripdata_partitioned_clustered`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- HQ Question 8
--- Write a `SELECT count(*)` query FROM the materialized table you created. How many bytes does it estimate will be read? Why?
SELECT COUNT(*) as total_count
FROM de-zoomcamp-davidrd123.ny_taxi.green_tripdata_non_partitioned;



-- Create a partitioned table from external table
CREATE OR REPLACE TABLE de-zoomcamp-davidrd123.ny_taxi.yellow_tripdata_partitoned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM de-zoomcamp-davidrd123.ny_taxi.yellow_cab_data;


-- Create a partitioned table from external table
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitoned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- Impact of partition
-- Scanning 1.6GB of data
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_non_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Impact of partition
-- Scanning 1.6GB of data
SELECT DISTINCT(VendorID)
FROM de-zoomcamp-davidrd123.ny_taxi.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning ~106 MB of DATA
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Let's look into the partitons
SELECT table_name, partition_id, total_rows
FROM `ny_taxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitoned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE de-zoomcamp-davidrd123.ny_taxi.yellow_tripdata_partitoned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM de-zoomcamp-davidrd123.ny_taxi.yellow_cab_data;

-- Query scans 1.1 GB
SELECT count(*) as trips
FROM de-zoomcamp-davidrd123.ny_taxi.yellow_tripdata_partitoned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

-- Query scans 864.5 MB
SELECT count(*) as trips
FROM de-zoomcamp-davidrd123.ny_taxi.yellow_tripdata_partitoned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

