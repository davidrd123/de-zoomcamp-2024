#!/usr/bin/env python
# coding: utf-8

import argparse
from time import time

import pandas as pd 
from sqlalchemy import create_engine
import os

def download_csv(url, csv_name=None):
    if csv_name is None:
        csv_name = url.split('/')[-1]
    result = os.system(f'wget -O {csv_name} {url}')
    if result != 0:
        raise Exception(f'Failed to download csv file from {url}')
    return csv_name

def connect_to_db(user, password, host, port, db):
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
    try:
        engine.connect()
    except Exception as e:
        raise Exception(f'Failed to connect to database {db} on {host}:{port} with user {user}')
    return engine

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url
    
    # Download the csv file
    csv_name = download_csv(url)
    engine = connect_to_db(user, password, host, port, db)
    print(f'connected to db {db} on {host}:{port} with user {user}')
    
    # Check if the file is a gzip file
    if csv_name.endswith('.gz'):
        compression = 'gzip'
    else:
        compression = None
    

    df_small = pd.read_csv(csv_name, nrows=5, compression=compression)
    df_small.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000, compression=compression)

    for df in df_iter:
        t_start = time()
        
        for col in df.columns:
            if 'datetime' in col:
                df[col] = pd.to_datetime(df[col])                        
        
        df.to_sql(name=table_name, con=engine, if_exists='append')
        
        t_end = time()
        print(f'inserted another chunk, took {t_end - t_start:.3f} seconds')
    
    print('done')

if __name__ == '__main__':
    print('starting')
    parser = argparse.ArgumentParser(description='Ingest CSV data into Postgres')
    print('adding arguments')
    # user, password, host, port, database name, table name, url of the csv file
    parser.add_argument('--user', type=str, help='user name for postgres')
    parser.add_argument('--password', type=str, help='password for postgres')
    parser.add_argument('--host', type=str, help='host for postgres')
    parser.add_argument('--port', type=str, help='port for postgres')
    parser.add_argument('--db', type=str, help='database name for postgres')
    parser.add_argument('--table_name', type=str, help='name of the table to write to')
    parser.add_argument('--url', type=str, help='url of the csv file to ingest')

    print('parsing args')
    args = parser.parse_args()
    
    print(f'args: {args}')
    main(args)





