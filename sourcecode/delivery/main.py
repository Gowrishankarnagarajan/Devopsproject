# delivery/main.py
from fastapi import FastAPI

app = FastAPI()

@app.post("/deliver")
def deliver_package(payload: dict):
    # Simulate delivery confirmation
    return {"status": "Delivered", "location": payload.get("destination")}