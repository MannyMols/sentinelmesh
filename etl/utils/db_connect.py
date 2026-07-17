import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

def get_engine():
    host     = os.getenv("DB_HOST", "localhost")
    port     = os.getenv("DB_PORT", "5432")
    dbname   = os.getenv("DB_NAME", "sentinelmesh_db")
    user     = os.getenv("DB_USER", "sentinel_user")
    password = os.getenv("DB_PASSWORD", "")
    if not password:
        raise RuntimeError("DB_PASSWORD not found. Set it in your .env file before running this.")

    url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{dbname}"
    return create_engine(url, pool_pre_ping=True)

def test_connection():
    engine = get_engine()
    with engine.connect() as conn:
        result = conn.execute(text("SELECT current_user, current_database(), version()"))
        row = result.fetchone()
        print(f"✅ Connected as : {row[0]}")
        print(f"✅ Database     : {row[1]}")
        print(f"✅ Version      : {row[2][:40]}")

if __name__ == "__main__":
    test_connection()
