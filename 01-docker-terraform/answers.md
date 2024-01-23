## Question 1:  Which tag has the following text? - *Automatically remove the container when it exits* 

### Answer:

```text
`--rm`
```

## Question 2: What is version of the package *wheel* ?

### Answer:
```txt
wheel      0.42.0
```

## Question 3. Count records 

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18. 

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- 15612
- 15859
- 89009

### Answer:
```sql
SELECT
	COUNT(*)
FROM
	"2019_trip" t
WHERE 
	CAST(lpep_pickup_datetime as DATE) = '2019-09-18' AND
	CAST(lpep_dropoff_datetime as DATE) = '2019-09-18'
LIMIT 100;
```

```text
15612
```


## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- 2019-09-26
- 2019-09-21

### Answer:

```sql
SELECT
	CAST(lpep_pickup_datetime as DATE) as "pickup_day",
	MAX(trip_distance) as "max_trip_distance"
FROM
	"2019_trip" t
GROUP BY
	"pickup_day"
ORDER BY
	"max_trip_distance" DESC
LIMIT 1;
```

```text
2019-09-26
```


## Question 5. The number of passengers

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
 
- "Brooklyn" "Manhattan" "Queens"
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens" 
- "Brooklyn" "Queens" "Staten Island"

### Answer:

```sql
SELECT
	tz."Borough",
	SUM(t.total_amount) as "total_amt_sum"
FROM
	"2019_trip" t JOIN taxi_zones tz
		ON t."PULocationID" = tz."LocationID"
WHERE
	 CAST(lpep_pickup_datetime as DATE) = '2019-09-18' AND
	 tz."Borough" != 'Unknown'
GROUP BY
	tz."Borough"
HAVING
	SUM(t.total_amount) > 50000
ORDER BY
	"total_amt_sum" DESC
LIMIT 3;
```

| Borough   | total_amt_sum       |
|-----------|---------------------|
| Brooklyn  | 96333.23999999944   |
| Manhattan | 92271.2999999985    |
| Queens    | 78671.70999999886   |

```text
- "Brooklyn", "Manhattan", "Queens"
```

## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

- Central Park
- Jamaica
- JFK Airport
- Long Island City/Queens Plaza

### Answer:

```sql
SELECT
	tzo."Zone",
	Max(t.tip_amount) as "max_tip"
FROM
	"2019_trip" t JOIN taxi_zones tzu
		ON t."PULocationID" = tzu."LocationID"
	JOIN taxi_zones tzo
		ON t."DOLocationID" = tzo."LocationID"
WHERE
	EXTRACT(YEAR FROM CAST(lpep_pickup_datetime AS Date)) = 2019 AND
	EXTRACT(MONTH FROM CAST(lpep_pickup_datetime AS Date)) = 9 AND
	tzu."Zone" = 'Astoria'
GROUP BY
	tzo."Zone"
ORDER BY
	"max_tip" DESC
LIMIT 4;
```

| "Zone"	| "max_tip"
----------|------------
| "JFK Airport"| 	62.31
| "Woodside"	| 30
| "Kips Bay"| 	28
| "NV"	| 25

```text
- JFK Airport
```

## Question 7. Creating Resources

After updating the main.tf and variable.tf files run:

```
terraform apply
```

Paste the output of this command into the homework submission form.

```txt
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.trip_data_dataset will be created
  + resource "google_bigquery_dataset" "trip_data_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "trips_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "de-zoomcamp-davidrd123"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.trip_data_bucket will be created
  + resource "google_storage_bucket" "trip_data_bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "nyctaxi-zoomcamp-davidrd123"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```