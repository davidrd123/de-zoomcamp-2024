#!/bin/bash

# Define start and end dates
start_year=2019
start_month=1
end_year=2020
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
        
        # Construct the URL
        url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_${year}-${month}.csv.gz"
        
        # Download the file
        wget $url -O temp.csv.gz
        
        # Upload to GCS
        gsutil cp temp.csv.gz gs://${bucket_name}/tripdata/yellow_tripdata_${year}-${month}.csv.gz
        
        # Remove the downloaded file to save space
        rm temp.csv.gz
    done
done