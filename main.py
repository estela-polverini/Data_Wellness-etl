from google.cloud import bigquery
import pandas as pd
import os
import numpy as np
from dotenv import load_dotenv
from pandas import DataFrame

load_dotenv()

PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET = os.getenv("BQ_DATASET")



def extract_from_local(path : str) -> DataFrame:

    df = pd.read_csv(path)

    print(df.head())
    df.info()
    print("Valores nulos:")
    print(df.isnull().sum())

    return df

def transform_data(df: DataFrame) -> DataFrame:
    print("Iniciando transformação...")
    #snake case
    df.columns = (
        df.columns
        .str.lower()
        .str.strip()
        .str.replace(" ", "_")
    )

    # -1 para cd nulos
    df["cd_unidade_atendimento"] = (
        df["cd_unidade_atendimento"]
        .fillna(-1)
        .astype(int)
    )

    # ds_atendimento nulos
    df["ds_unidade_atendimento"] = (
        df["ds_unidade_atendimento"]
        .fillna("Não Informado")
    )

    print("Datas inválidas:", 
          df["dt_nascimento"].isna().sum())

    #idade calculada
    df["dt_nascimento"] = pd.to_datetime(
        df["dt_nascimento"],
        errors="coerce"
    )
    df["idade"] = calcular_idade(df["dt_nascimento"])
    df["idade"] = (
        df["idade"]
        .fillna(-1)
        .astype(int)
    )

    #alteração de tipagem
    df["ano"] = df["ano"].astype(int)
    df["cd_paciente"] = df["cd_paciente"].astype(int)

    print("Transformação concluída!")

    return df

def calcular_idade(dt_nascimento: pd.Series) -> pd.Series:
    hoje = pd.Timestamp.today()

    idade = hoje.year - dt_nascimento.dt.year
    fez_aniversario = (
        (hoje.month > dt_nascimento.dt.month) |
        (
            (hoje.month == dt_nascimento.dt.month) &
            (hoje.day >= dt_nascimento.dt.day)
        )
    )

    idade = idade - (~fez_aniversario)

    return idade

def get_bq_client():
    return bigquery.Client(project=PROJECT_ID)


def load_to_bq(df: DataFrame, table_name: str):
    client = get_bq_client()
    table_id = f"{client.project}.{DATASET}.{table_name}"

    job = client.load_table_from_dataframe(df, table_id)
    job.result()

    print(f"Dados enviados para {table_id}")

def main():
    print("Inicio do ETL...")

    path_materdei = r'extract\materdei-data.csv'
    path_novo = r'extract\dataset-no-shows.csv'

    df_materdei = extract_from_local(path_materdei)
    df_novo = extract_from_local(path_novo)

    df_tratado = transform_data(df_materdei)
    print(df_tratado.head())
    df_tratado.info()


    load_to_bq(df_tratado, "materdei")

    print("ETL finalizado!")


if __name__ == "__main__":
    main()