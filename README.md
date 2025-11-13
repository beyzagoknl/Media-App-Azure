# Azure Media Processing Pipeline

This project replicates an AWS-style media processing pipeline using Azure services.
It allows users to upload files through a Flask API, which are then processed asynchronously using Azure Blob Storage, Queue, Event Grid, and AKS (Azure Kubernetes Service).
All infrastructure is provisioned via Terraform, and images are managed through Azure Container Registry (ACR).

## Architecture Overview

```text
                 +-----------------------------+
                 |         User Client         |
                 |   POST /upload (via Flask)  |
                 +-------------+---------------+
                               |
                               v
                 +-----------------------------+
                 |  Uploader (Flask API on AKS)|
                 |  - Receives file uploads     |
                 |  - Stores in RAW container   |
                 +-------------+---------------+
                               |
                               | (EventGrid triggers)
                               v
                 +-----------------------------+
                 |   Azure Storage Queue        |
                 |   (jobqueue)                 |
                 +-------------+---------------+
                               |
                               v
                 +-----------------------------+
                 | Processor (Worker on AKS)   |
                 | - Reads queue messages      |
                 | - Copies blobs to PROCESSED |
                 +-------------+---------------+
                               |
                               v
                 +-----------------------------+
                 |   Azure Blob Storage         |
                 |   rawfiles → processed       |
                 +-----------------------------+

  Infrastructure layer:
  ┌────────────────────────────────────────────────────────────┐
  │ Terraform creates:                                          │
  │  • Resource Group                                           │
  │  • Storage Account + Containers + Queue                     │
  │  • Event Grid System Topic                                  │
  │  • Azure Container Registry (ACR)                           │
  │  • Azure Kubernetes Service (AKS)                           │
  │  • Role Assignments (ACR Pull, Blob Contributor)            │
  └────────────────────────────────────────────────────────────┘
```

## Components

| Component | Description |
|------------|-------------|
| Uploader | Flask API service for uploading files into the “rawfiles” container. |
| Processor | Background service that listens to the Azure Queue and copies files to the “processed” container. |
| Terraform | Defines Azure infrastructure — including Resource Group, Storage Account, Queue, ACR, AKS, and permissions. |
| Docker Compose | Optional local setup to simulate both services without Azure. |

## Deployment on Azure

### 1. Create Infrastructure
```bash
cd infra
terraform init
terraform apply -auto-approve
```

### 2. Build and Push Docker Images
```bash
cd app
docker build -t $ACR_NAME.azurecr.io/uploader:latest .
docker tag $ACR_NAME.azurecr.io/uploader:latest $ACR_NAME.azurecr.io/processor:latest
az acr login --name $ACR_NAME
docker push $ACR_NAME.azurecr.io/uploader:latest
docker push $ACR_NAME.azurecr.io/processor:latest
```

### 3. Deploy to AKS
```bash
az aks get-credentials --resource-group rg-media --name aks-bg-challenge
kubectl apply -f k8s/uploader-deployment.yaml
kubectl apply -f k8s/processor-deployment.yaml
kubectl get svc uploader-service --watch
```

Once the external IP is available, test file upload:
```bash
curl -F "file=@./heyo.png" http://<PUBLIC_IP>/upload
```

## Run Locally (No Azure)

You can simulate the full pipeline locally using Docker Compose and your Azure Storage credentials.

### 1. Create a .env file
```bash
STORAGE_ACCOUNT_NAME=your_storage_account_name
STORAGE_ACCOUNT_KEY=your_storage_account_key
```

### 2. Start the stack
```bash
docker compose up --build
```

Uploader API → http://localhost:8000/upload

## Tech Stack

- Azure Blob Storage
- Azure Queue Storage
- Azure Event Grid
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- Terraform
- Flask (Python)
- Docker & Docker Compose

## Secrets and Access

Terraform automatically creates and binds:
- Storage Blob Data Contributor to AKS managed identity.
- AcrPull role for AKS nodes to pull images from ACR.

All storage keys are securely injected into Kubernetes as Secrets.


