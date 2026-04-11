from google.cloud import bigquery
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET = os.getenv("BQ_DATASET")


def get_bq_client():
    return bigquery.Client(project=PROJECT_ID)

def load_to_bq(df, table_name):
    client = get_bq_client()
    table_id = f"{client.project}.{DATASET}.{table_name}"
    job = client.load_table_from_dataframe(df, table_id)
    job.result()

    print(f"Dados enviados para {table_id}")

def extract_from_local():
    df = pd.read_csv("extract\materdei-data.csv")
    print(df.head())
    print(df.info())

def main():
    print("Inicio do ETL...")
    extract_from_local()

if __name__ == "__main__":
    main()