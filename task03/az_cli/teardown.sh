#!/bin/bash


#############
# Variables #
#############

LOCATION="westeurope"
RESOURCE_GROUP="task3"
VPC="vpc3"
VPC_CIDR="10.3.0.0/16"
SUBNET1="subnet1"
SUBNET1_CDR="10.3.1.0/24"
PUBLIC_IP="public-ip-3"
NSG="nsg3"
NIC="nic3"
VM="vm3"

#############
# Resources #
#############

echo "Deleting vm"
az vm delete \
   --force-deletion yes \
   --name ${VM} \
   --resource-group ${RESOURCE_GROUP} \
   --yes 

echo "Deleting nic"
az network nic delete \
   --name ${NIC} \
   --resource-group ${RESOURCE_GROUP}

echo "Deleting network security group"
az network nsg delete \
   --name ${NSG} \
   --resource-group ${RESOURCE_GROUP}

echo "Deleting public ip"
az network public-ip delete \
   --name ${PUBLIC_IP} \
   --resource-group ${RESOURCE_GROUP}

echo "Deleting VPC"
az network vnet delete \
   --name ${VPC} \
   --resource-group ${RESOURCE_GROUP}

echo "Deleting resource group"
az group delete \
   --name ${RESOURCE_GROUP} \
   --yes 
