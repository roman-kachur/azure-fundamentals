#!/bin/bash


#############
# Variables #
#############

LOCATION="westus"
RESOURCE_GROUP="task5"

#############
# Resources #
#############

echo "Deleting web app with default webapp service"
az webapp delete \
   --name webapp-task05 \
   --resource-group ${RESOURCE_GROUP} \

echo "Deleting resource group"
az group delete \
   --name ${RESOURCE_GROUP} \
   --yes 
