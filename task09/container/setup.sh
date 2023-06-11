#!/bin/bash

#############
# Variables #
#############

LOCATION="uksouth"
RESOURCE_GROUP="task09"
REGISTRY="registry09task09"

#############
# Resources #
#############

echo "Creating resource group"
az group create \
   --name ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --output none

echo "Creating container registry"
az acr create \
   --name ${REGISTRY} \
   --resource-group ${RESOURCE_GROUP} \
   --sku Standard \
   --location ${LOCATION} \
   --output none

az acr update \
   --name ${REGISTRY} \
   --anonymous-pull-enabled true \
   --output none

echo "Building image"
az acr build \
   --image app1:v1 \
   --registry ${REGISTRY} \
   --file Dockerfile \
   . \
   --output none \
   --no-logs

echo "Running container"
URL=$(az container create \
   --resource-group ${RESOURCE_GROUP} \
   --name application1 \
   --image ${REGISTRY}.azurecr.io/app1:v1 \
   --dns-name-label task09 \
   --port 80 \
   --registry-login-server ${REGISTRY}.azurecr.io \
   --registry-password anonymous \
   --registry-username anonymous \
   --query ipAddress.fqdn \
   --output tsv)

sleep 45
echo "Check application:"   
curl http://$URL
