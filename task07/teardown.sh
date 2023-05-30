#!/bin/bash


#############
# Variables #
#############

LOCATION="uksouth"
RESOURCE_GROUP="task07"
KEY_VAULT="keyvault07"
SECRET="password1"
VPC="vpc3"
VPC_CIDR="10.7.0.0/16"
SUBNET1="subnet1"
SUBNET1_CDR="10.7.1.0/24"
PUBLIC_IP="public-ip-7"
NSG="nsg7"
NIC="nic7"
VM="vm7"

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

echo "Purging Key vault"
az keyvault purge \
   --name ${KEY_VAULT} \
   --location ${LOCATION} \
   --no-wait
