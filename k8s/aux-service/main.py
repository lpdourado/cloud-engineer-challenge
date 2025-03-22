from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from Auxiliary Service", "region": "eu-west-1"}
