### Overview

This document provides a comprehensive overview of the Kubernetes deployment process for the aux-service application, covering all configurations, technologies, and stack components used.

## Technologies and Stack

The following technologies and services were utilized for this deployment:
- Docker: Containerization of the application.
- Kubernetes: Orchestration and management of the containerized application.
- FastAPI: Python-based web framework used for building the API.
- AWS S3: Cloud storage service used for listing buckets.
- AWS SSM Parameter Store: Service used to manage configuration parameters.
- AWS IAM Roles: Recommended for secure access to AWS services.
- kubectl: CLI tool for interacting with the Kubernetes cluster.
- Kubernetes Services: Exposing the application to internal or external clients.

## Terraform

Terraform was used to provision AWS resources such as AWS IAM roles, policies, S3 buckets, SSM parameters, and store tfstate file into AWS.

Terraform structure:

terraform
  |
  |__backend.tf
  |__iam_policy_attachment.tf
  |__iam_policy.tf
  |__iam_role.tf
  |__main.tf
  |__output.tf
  |__provider.tf
  


## CI/CD GitHub Actions

GitHub Actions was used to automate the deployment process.


name: CI/CD Pipeline

on:
    push:
        branches:
            - master
            
    pull_request:
        branches:
            - master


jobs:
    build-and-push:
        name: Build & Push Docker Images
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Set up Docker Buildx
              uses: docker/setup-buildx-action@v3

            - name: Log in to Docker Uhb
              run: |
                echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin
                docker info  # Debug to check if login was successful

            - name: Build and Push Main API
              run: |
                docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/main-api:latest -f k8s/main-api/Dockerfile k8s/main-api
                docker push ${{ secrets.DOCKERHUB_USERNAME }}/main-api:latest
            
            - name: Build and Push Aux Service
              run: |
                docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/aux-service:latest -f  k8s/aux-service/Dockerfile k8s/aux-service
                docker push ${{ secrets.DOCKERHUB_USERNAME }}/aux-service:latest
    deploy:
        name: Deploy to Kubernetes
        needs: build-and-push
        runs-on: self-hosted
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Configure Kubeconfig
              run: |
                echo "${{ secrets.KUBECONFIG }}" | base64 --decode > ~/.kube/config
                export KUBECONFIG=kubeconfig.yaml

            - name: Set up Kubeconfig
              run: |
                kubectl config current-context
                kubectl cluster-info

            - name: Apply Kubernetes Manifests
              run: |
                kubectl apply -f k8s/main-api/
                kubectl apply -f k8s/aux-service/
            
            - name: Debug GitHub Secrets
              run: |
                echo "ARGOCD_SERVER: ${{ secrets.ARGOCD_SERVER }}"
                echo "ARGOCD_TOKEN: ${{ secrets.ARGOCD_TOKEN }}"
              

            - name: Authenticate with ArgoCD
              run: |
                argocd login ${{ secrets.ARGOCD_SERVER }} --username "${{ secrets.ARGOCD_USERNAME }}" --password "${{ secrets.ARGOCD_PASSWORD }}" --grpc-web --insecure

            - name:
              run: |
                argocd app sync argocd/main-api-app
                argocd app sync argocd/aux-service-app



## Application Details

# Main API (main-api)

This service includes integration with AWS S3 and AWS SSM to retrieve and manage cloud resources.

Code Implementation:


from fastapi import FastAPI
import os
import boto3

app = FastAPI()

aws_region = os.getenv("AWS_REGION", "eu-west-1")

s3_client = boto3.client("s3", region_name=aws_region)
ssm_client = boto3.client("ssm", region_name=aws_region)

@app.get("/")
def read_root():
    return {"message": "Hello from Main API", "region": aws_region}

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



#Auxiliary Service (aux-service)

This service includes integration with AWS S3 and AWS SSM to retrieve and manage cloud resources.

Code Implementation:


from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from Auxiliary Service", "region": "eu-west-1"}



## Docker Implementation

The application was containerized using Docker. The docker run command used for running the service locally was:


docker run -p 8000:8000 \
  -e AWS_REGION=us-east-1 \
  -e AWS_PROFILE=default \
  -v ~/.aws:/root/.aws \
  main-api


This command:
- Maps port 8000 of the container to 8000 on the host.
- Passes environment variables (AWS_REGION and AWS_PROFILE).
- Mounts AWS credentials for access to AWS services.

## Kubernetes Deployment

To deploy the application in Kubernetes, the following deployment.yaml manifest was created:


apiVersion: apps/v1
kind: Deployment
metadata:
  name: main-api
  namespace: cloud-engineer-challenge
spec:
  replicas: 2
  selector:
    matchLabels:
      app: main-api
  template:
    metadata:
      labels:
        app: main-api
    spec:
      serviceAccountName: main-api
      containers:
        - name: main-api
          image: lpdourado/main-api:latest
          ports:
            - containerPort: 8000


Service Definition


apiVersion: v1
kind: Service
metadata:
  name: main-api
  namespace: cloud-engineer-challenge
spec:
  selector:
    app: main-api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: ClusterIP



Service Account


apiVersion: v1
kind: ServiceAccount
metadata:
  name: main-api
  namespace: cloud-engineer-challenge
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::890742573274:role/GitHubActionsOIDC


## Deployment Process

To deploy the service in Kubernetes:


kubectl apply -f main-api-deployment.yaml


To check the running pods:


kubectl get pods
kubectl logs <pod-name>


To test the service:


kubectl port-forward service/main-api 8000:8000


Access via http://localhost:8001.

