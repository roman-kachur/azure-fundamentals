#!/bin/bash

#############
# Variables #
#############

LOCATION="uksouth"
RESOURCE_GROUP="task09aks"
REGISTRY="registry09task09aks"
VPC="vpc9"
VPC_CIDR="10.0.0.0/8"
SUBNET1="subnet1"
SUBNET_VN="subnet_vn"
SUBNET1_CIDR="10.1.0.0/16"
SUBNET_VN_CIDR="10.2.0.0/16"
CLUSTER="cluster09"
DEPLOYMENT="deployment1"

#############
# Resources #
#############

echo "Create resource group"
az group create \
   --name ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --output none

echo "Create vpc and two subnets for k8s nodes"
az network vnet create \
   --name ${VPC} \
   --resource-group ${RESOURCE_GROUP} \
   --address-prefixes ${VPC_CIDR} \
   --output none

SUBNET1_ID=$(az network vnet subnet create \
   --name ${SUBNET1} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --address-prefixes ${SUBNET1_CIDR} \
   --query id \
   --output tsv)

az network vnet subnet create \
   --name ${SUBNET_VN} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --address-prefixes ${SUBNET_VN_CIDR} \
   --output none

echo "Create container registry"
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

echo "Build two images v1 and v2"
az acr build \
   --image app1:v1 \
   --registry ${REGISTRY} \
   --file Dockerfile1 \
   . \
   --output none \
   --no-logs

az acr build \
   --image app1:v2 \
   --registry ${REGISTRY} \
   --file Dockerfile2 \
   . \
   --output none \
   --no-logs

echo "Create AKS"
az aks create \
   --name ${CLUSTER} \
   --resource-group ${RESOURCE_GROUP} \
   --tier free \
   --node-count 2 \
   --network-plugin azure \
   --generate-ssh-keys \
   --node-vm-size Standard_B2s \
   --node-osdisk-size 30 \
   --vnet-subnet-id ${SUBNET1_ID} \
   --output none

#az aks enable-addons \
#   --resource-group ${RESOURCE_GROUP} \
#   --name ${CLUSTER} \
#   --addons virtual-node \
#   --subnet-name ${SUBNET_VN} \
#   --output none

echo "Get k8s credentials"
az aks get-credentials \
   --resource-group ${RESOURCE_GROUP} \
   --name ${CLUSTER} \
   --overwrite-existing \
   --output none

echo "Create deployment from image1"
kubectl create deployment \
   ${DEPLOYMENT} \
   --image ${REGISTRY}.azurecr.io/app1:v1 \
   --replicas=2

sleep 30
echo "Expose service"
kubectl expose deployment \
   ${DEPLOYMENT} \
   --type=LoadBalancer \
   --port=80 \
   --target-port=80

sleep 45
IP=$(kubectl get service \
   ${DEPLOYMENT} \
   -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Service IP is ${IP}"

echo ""
echo "HTTP response from service is"
curl ${IP}

echo ""
echo "Update deployment to version 2"
kubectl set image \
   deployment/${DEPLOYMENT} \
   app1=${REGISTRY}.azurecr.io/app1:v2

sleep 15
echo ""
echo "HTTP response from service is"
curl ${IP}

echo ""
echo "Rollback deployment to version 1"
kubectl rollout undo deployment/${DEPLOYMENT}

sleep 15
echo ""
echo "HTTP response from service is"
curl ${IP}
