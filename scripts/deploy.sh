#!/bin/bash
set -e

echo "Creating Terraform infrastructure..."
cd infra
terraform init -upgrade
terraform apply -auto-approve
cd ..

echo "Fetching Terraform outputs..."
ACR_NAME=$(terraform -chdir=infra output -raw acr_name)
STORAGE_ACCOUNT_NAME=$(terraform -chdir=infra output -raw storage_account)

echo "Building Docker images..."
cd app
docker build -t $ACR_NAME.azurecr.io/uploader:latest .
docker tag $ACR_NAME.azurecr.io/uploader:latest $ACR_NAME.azurecr.io/processor:latest
cd ..

echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

echo "Pushing Docker images to ACR..."
docker push $ACR_NAME.azurecr.io/uploader:latest
docker push $ACR_NAME.azurecr.io/processor:latest

echo "Configuring AKS credentials..."
az aks get-credentials --resource-group rg-media --name aks-bg-challenge --overwrite-existing

echo "Deploying Kubernetes manifests..."
sed -e "s#<ACR_NAME>#$ACR_NAME#g" -e "s#<STORAGE_ACCOUNT_NAME>#$STORAGE_ACCOUNT_NAME#g" k8s/uploader-deployment.yaml | kubectl apply -f -
sed -e "s#<ACR_NAME>#$ACR_NAME#g" -e "s#<STORAGE_ACCOUNT_NAME>#$STORAGE_ACCOUNT_NAME#g" k8s/processor-deployment.yaml | kubectl apply -f -

echo "Waiting for external IP address..."
kubectl get svc uploader-service --watch