from repositories.base_repository import BaseRepository


class IngestionService():

    def __init__(self):
        self.repo = BaseRepository()

    def ingest_csv_to_db(self, file_path, kind, client, period):
        return self.repo.store_csv_to_db(file_path, kind, client, period)