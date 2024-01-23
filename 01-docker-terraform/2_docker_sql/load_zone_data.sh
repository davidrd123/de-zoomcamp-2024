#!/bin/bash

docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
  --user=root \
  --password=root \
  --host=pg-database \
  --port=5432 \
  --db=ny_taxi \
  --table_name=taxi_zones \
  --url="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"

