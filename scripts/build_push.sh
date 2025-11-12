#!/usr/bin/env bash
set -euo pipefail
ACR_SERVER="$1" # e.g. bgacr1234.azurecr.io

echo "Logging into ACR: $ACR_SERVER"
az acr login --name "${ACR_SERVER%%.*}"

echo "Building uploader..."
docker build -t $ACR_SERVER/uploader:latest ./apps/uploader
docker push $ACR_SERVER/uploader:latest

echo "Building processor..."
docker build -t $ACR_SERVER/processor:latest ./apps/processor
docker push $ACR_SERVER/processor:latest

echo "Done."
