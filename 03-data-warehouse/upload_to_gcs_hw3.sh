#!/bin/bash

# Define start and end dates
start_year=2022
start_month=1
end_year=2022
end_month=12

# Define the bucket name
bucket_name="nyctaxi-zoomcamp-davidrd123"

# Loop over years and months
for year in $(seq $start_year $end_year); do
    for month in $(seq -f "%02g" 1 12); do
        # Skip months outside the range for the first and last year
        if [ $year -eq $start_year -a $month -lt $start_month ]; then
            continue
        fi
        if [ $year -eq $end_year -a $month -gt $end_month ]; then
            break
        fi

        url="https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_${year}-${month}.parquet"
        
        # Construct the URL
        # url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_${year}-${month}.csv.gz"
        
        # Download the file
        wget $url -O temp.parquet
        
        # Upload to GCS
        gsutil cp temp.parquet gs://${bucket_name}/green_taxi_${year}/green_tripdata_${year}-${month}.parquet
        
        # Remove the downloaded file to save space
        rm temp.parquet
    done
done