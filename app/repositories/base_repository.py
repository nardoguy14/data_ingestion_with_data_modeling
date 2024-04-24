import pandas as pd
from sqlalchemy import create_engine
import os


class BaseRepository():

    def __init__(self):
        database_name = os.environ.get("POSTGRES_DB")
        username = os.environ.get("POSTGRES_USER")
        password = os.environ.get("POSTGRES_PASSWORD")
        host = os.environ.get("POSTGRES_HOST")
        self.url = f"postgresql://{username}:{password}@{host}:5432/{database_name}"
        self.engine = create_engine(self.url)

    def get_df(self, file_path, file_type):
        if file_type == "csv":
            print("picked csv type")
            df = pd.read_csv(file_path)
            return df
        elif file_type == "xlsx":
            print("picked excel type")
            df = pd.read_excel(file_path)
            return df

    def store_csv_to_db(self, file_path: str, kind, client, period):
        filename = file_path.split("/")[-1]
        file_type = filename.split(".")[1]
        print(f"filetype: {file_type}")
        df = self.get_df(file_path, file_type)
        df['file_defined_period'] = period
        print(f"using url {self.url}")

        return df.to_sql(f"{kind}_{client}", self.engine, schema="export", if_exists='append', index=False)
