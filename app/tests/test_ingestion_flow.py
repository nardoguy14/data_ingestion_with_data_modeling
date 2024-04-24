import os
import pytest
import psycopg2

database_name = os.environ.get("POSTGRES_DB")
username = os.environ.get("POSTGRES_USER")
password = os.environ.get("POSTGRES_PASSWORD")
host = "localhost" # cant use environment variable because its docker.for.mac which is onlyt o be used in container
db_params = {
    'dbname': database_name,
    'user': username,
    'password': password,
    'host': host,
    'port': '5432'
}

def test_run_end_to_end_ingestion():
    conn = psycopg2.connect(**db_params)
    cursor = conn.cursor()
    query = 'SELECT * FROM "export"."patient_registration_clientA"'
    cursor.execute(query)
    rows = cursor.fetchall()
    print(f"amount of rows present: {len(rows)}")
    assert len(rows) == 54
