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

echo "Creating resource group"
az group create \
   --name ${RESOURCE_GROUP} \
   --location ${LOCATION}

echo "Creating vpc and subnet"
az network vnet create \
   --name ${VPC} \
   --resource-group ${RESOURCE_GROUP} \
   --address-prefixes ${VPC_CIDR}

az network vnet subnet create \
   --name ${SUBNET1} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --address-prefixes ${SUBNET1_CDR}

echo "Allocate public ip address"
PUBLIC_IP_ADDRESS=$(az network public-ip create \
   --name ${PUBLIC_IP} \
   --resource-group  ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --allocation-method Static \
   --sku Basic \
   --tags Name=ip-3 \
   --query publicIp.ipAddress \
   --outpu tsv)

echo ${PUBLIC_IP_ADDRESS}

echo "Creating network security group"
az network nsg create \
   --name ${NSG} \
   --resource-group ${RESOURCE_GROUP} \
   --location ${LOCATION}

echo "Opening ports 80 for NSG"
az network nsg rule create \
   --name open80 \
   --nsg-name ${NSG} \
   --resource-group ${RESOURCE_GROUP} \
   --priority 100 \
   --source-address-prefixes Internet \
   --destination-port-ranges 80 \
   --access Allow \
   --protocol Tcp 

echo "Creating nic for vm"
az network nic create \
   --location ${LOCATION} \
   --name ${NIC} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --subnet ${SUBNET1} \
   --accelerated-networking false \
   --network-security-group ${NSG} \
   --public-ip-address ${PUBLIC_IP}

echo "Launching vm"
az vm create \
   --name ${VM} \
   --resource-group ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --image Ubuntu2204 \
   --size Standard_B1ls \
   --generate-ssh-keys \
   --storage-sku Standard_LRS \
   --nics ${NIC} \
   --os-disk-delete-option Delete \
   --custom-data custom-data.txt

echo "Waiting 3 minutes for provisioning custom-data"
sleep 180

echo "curl http://${PUBLIC_IP_ADDRESS}"
curl http://${PUBLIC_IP_ADDRESS}
