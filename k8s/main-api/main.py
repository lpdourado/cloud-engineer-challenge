from fastapi import FastAPI
import os
import boto3

app = FastAPI()

aws_region = os.getenv("AWS_REGION", "eu-west-1")

s3_client = boto3.client("s3", region_name=aws_region)
ssm_client = boto3.client("ssm", region_name=aws_region)

@app.get("/")
def read_root():
    return {"message": "Hello from Main API"}

@app.get("/s3-buckets")
def list_s3_buckets():
    """List all S3 buckets in the AWS account."""
    try:
        response = s3_client.list_buckets()
        bucket_names = [bucket["Name"] for bucket in response["Buckets"]]
        return {"buckets": bucket_names, "service_version": "1.0.0"}
    except Exception as e:
        return {"error": str(e), "service_version": "1.0.0"}

@app.get("/parameters")
def list_ssm_parameters():
    """List all AWS SSM parameters."""
    try:
        response = ssm_client.describe_parameters()
        param_names = [param["Name"] for param in response["Parameters"]]
        return {"parameters": param_names, "service_version": "1.0.0"}
    except Exception as e:
        return {"error": str(e), "service_version": "1.0.0"}

@app.get("/parameter/{name}")
def get_ssm_parameter(name: str):
    """Retrieve a specific parameter from AWS Parameter Store."""
    try:
        response = ssm_client.get_parameter(Name=name, WithDecryption=True)
        return {"parameter": response["Parameter"]["Value"], "service_version": "1.0.0"}
    except Exception as e:
        return {"error": str(e), "service_version": "1.0.0"}
