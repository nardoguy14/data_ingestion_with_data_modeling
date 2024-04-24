import psycopg2
import os
import sqlparse
import time
from tenacity import retry, stop_after_delay, wait_fixed

database_name = os.environ.get("POSTGRES_DB")
username = os.environ.get("POSTGRES_USER")
password = os.environ.get("POSTGRES_PASSWORD")
host = os.environ.get("POSTGRES_HOST")
time.sleep(5)
# Database connection parameters
db_params = {
    'dbname': database_name,
    'user': username,
    'password': password,
    'host': host,
    'port': '5432'
}

@retry(stop=stop_after_delay(30), wait=wait_fixed(2))
def connect_to_db():
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()
    return cur, conn

cur, conn = connect_to_db()
with open('./scripts/routine.sql', 'r') as file:
    sql_file = file.read()

print(sql_file)

statements = sqlparse.split(sql_file)

for statement in statements:
    cur.execute(statement)

cur.execute("""
    DO $$ 
    BEGIN 
        IF NOT EXISTS (
            SELECT schema_name 
            FROM information_schema.schemata 
            WHERE schema_name = 'export'
        ) THEN
            CREATE SCHEMA export;
        END IF;
    END $$;
""")

# Commit the transaction
conn.commit()

# Close cursor and connection
cur.close()
conn.close()

print("SQL file executed successfully!")
