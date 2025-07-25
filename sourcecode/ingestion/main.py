# ingestion/main.py
from fastapi import FastAPI

app = FastAPI()

@app.post("/ingest")
def ingest_data(payload: dict):
    # Simulate ingesting data
    return {"status": "Data ingested", "payload": payload}