# Use an official Python runtime as a parent image
FROM python:3.9.1

RUN apt-get install -y wget

RUN pip install pandas sqlalchemy psycopg2-binary psycopg2

WORKDIR /app

COPY ingest_data.py ingest_data.py
COPY ingest_data.sh ingest_data.sh

ENTRYPOINT [ "python", "ingest_data.py" ]



