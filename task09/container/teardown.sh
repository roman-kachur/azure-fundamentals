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

echo "Deleting container"
az container delete \
   --name application1 \
   --resource-group ${RESOURCE_GROUP} \
   --yes \
   --output none

echo "Deleting registry"
az acr delete \
   --name ${REGISTRY} \
   --resource-group ${RESOURCE_GROUP} \
   --yes \
   --output none

echo "Deleting resource group"
az group delete \
   --name ${RESOURCE_GROUP} \
   --yes
