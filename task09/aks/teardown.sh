#!/bin/bash

#############
# Variables #
#############

LOCATION="uksouth"
RESOURCE_GROUP="task09aks"
REGISTRY="registry09task09aks"
VPC="vpc9"
CLUSTER="cluster09"

#############
# Resources #
#############

echo "Delete AKS"
az aks delete \
   --name ${CLUSTER} \
   --resource-group ${RESOURCE_GROUP} \
   --yes

echo "Delete registry"
az acr delete \
   --name ${REGISTRY} \
   --resource-group ${RESOURCE_GROUP} \
   --yes \
   --output none

echo "Delete VPC"
az network vnet delete \
   --name ${VPC} \
   --resource-group ${RESOURCE_GROUP}

echo "Delete resource group"
az group delete \
   --name ${RESOURCE_GROUP} \
   --yes 
