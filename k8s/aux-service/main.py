import os
import boto3
from fastapi import FastAPI
from prometheus_fastpi_instrumentator import Instrumentator

app = FastAPI()

Instrumentator().instrument(app).expose(app)

aws_region = os.getenv("AWS_REGION", "eu-west-1")

# Initialize AWS clients
s3_client = boto3.client("s3", region_name=aws_region)
ssm_client = boto3.client("ssm", region_name=aws_region)

@app.get("/")
def read_root():
    return {"message": "Hello from Auxiliary Service", "region": aws_region}

@app.get("/s3-buckets")
def list_s3_buckets():
    """List all S3 buckets in the AWS account."""
    response = s3_client.list_buckets()
    bucket_names = [bucket["Name"] for bucket in response["Buckets"]]
    return {"buckets": bucket_names, "service_version": "1.0.0"}

@app.get("/parameters")
def list_ssm_parameters():
    """List all AWS SSM parameters."""
    response = ssm_client.describe_parameters()
    param_names = [param["Name"] for param in response["Parameters"]]
    return {"parameters": param_names, "service_version": "1.0.0"}

@app.get("/parameter/{name}")
def get_ssm_parameter(name: str):
    """Retrieve a specific parameter from AWS Parameter Store."""
    response = ssm_client.get_parameter(Name=name, WithDecryption=True)
    return {"parameter": response["Parameter"]["Value"], "service_version": "1.0.0"}
