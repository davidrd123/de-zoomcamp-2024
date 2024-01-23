variable "credentials" {
  description = "My Credentials"
  default     = "/home/davidrd/.config/gcloud/de-zoomcamp-davidrd123-137c680e81aa.json"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}


variable "project" {
  description = "Data Engineering Zoomcamp Project"
  default     = "de-zoomcamp-davidrd123"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default     = "us-west2"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default     = "US"
}

variable "bq_dataset_name" {
  description = "BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "trips_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "nyctaxi-zoomcamp-davidrd123"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}