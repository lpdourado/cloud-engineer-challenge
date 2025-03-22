from fastapi import FastAPI
from fastapi import FastAPI
from prometheus_fastpi_instrumentator import Instrumentator

app = FastAPI()

Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    return {"message": "Hello from Main API"}