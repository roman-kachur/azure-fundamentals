#!/bin/bash


#############
# Variables #
#############

LOCATION="westus"
RESOURCE_GROUP="task5"

#############
# Resources #
#############

echo "Creating resource group"
az group create \
   --name ${RESOURCE_GROUP} \
   --location ${LOCATION}

echo "Creating web app with default webapp service"
URL=$(az webapp up \
   --name webapp-task05 \
   --resource-group ${RESOURCE_GROUP} \
   --sku FREE \
   --html \
   --query URL \
   --output tsv)

echo "URL is: $URL"
