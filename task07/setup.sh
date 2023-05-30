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

echo "Generating randon password"
VM_PASSWORD=$(date | md5)"8@lT"

echo "Creating resource group"
az group create \
   --name ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --output none

echo "Creating key vault"
az keyvault create \
   --name ${KEY_VAULT} \
   --resource-group ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --output none

echo "Creating a secret"
az keyvault secret set \
   --name ${SECRET} \
   --vault-name ${KEY_VAULT} \
   --value ${VM_PASSWORD} \
   --output none

echo "New secret is:"
echo $(az keyvault secret show \
   --name ${SECRET} \
   --vault-name ${KEY_VAULT} \
   --query value \
   --output tsv)

echo "Creating vpc and subnet"
az network vnet create \
   --name ${VPC} \
   --resource-group ${RESOURCE_GROUP} \
   --address-prefixes ${VPC_CIDR} \
   --output none

az network vnet subnet create \
   --name ${SUBNET1} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --address-prefixes ${SUBNET1_CDR} \
   --output none

echo "Allocate public ip address"
PUBLIC_IP_ADDRESS=$(az network public-ip create \
   --name ${PUBLIC_IP} \
   --resource-group  ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --allocation-method Static \
   --sku Basic \
   --tags Name=ip-3 \
   --query publicIp.ipAddress \
   --output tsv)

echo ${PUBLIC_IP_ADDRESS}

echo "Creating network security group"
az network nsg create \
   --name ${NSG} \
   --resource-group ${RESOURCE_GROUP} \
   --location ${LOCATION} \
   --output none

echo "Opening ports 22 for NSG"
az network nsg rule create \
   --name open22 \
   --nsg-name ${NSG} \
   --resource-group ${RESOURCE_GROUP} \
   --priority 100 \
   --source-address-prefixes Internet \
   --destination-port-ranges 22 \
   --access Allow \
   --protocol Tcp \
   --output none

echo "Creating nic for vm"
az network nic create \
   --location ${LOCATION} \
   --name ${NIC} \
   --resource-group ${RESOURCE_GROUP} \
   --vnet-name ${VPC} \
   --subnet ${SUBNET1} \
   --accelerated-networking false \
   --network-security-group ${NSG} \
   --public-ip-address ${PUBLIC_IP} \
   --output none

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
   --admin-username azureadmin \
   --admin-password $(az keyvault secret show \
                        --name ${SECRET} \
                        --vault-name ${KEY_VAULT} \
                        --query value \
                        --output tsv)\
   --os-disk-delete-option Delete \
   --custom-data custom-data.txt \
   --output none

echo "Waiting 3 minutes for provisioning custom-data"
sleep 180

echo "curl http://${PUBLIC_IP_ADDRESS}"
echo "which shuld be dropped due to missing tcp/80 in nsg"
curl --connect-timeout 5 http://${PUBLIC_IP_ADDRESS}

echo "Opening ports 80 for NSG"
az network nsg rule create \
   --name open80 \
   --nsg-name ${NSG} \
   --resource-group ${RESOURCE_GROUP} \
   --priority 101 \
   --source-address-prefixes Internet \
   --destination-port-ranges 80 \
   --access Allow \
   --protocol Tcp \
   --output none

echo "Waiting 30 seconds for nsg"
sleep 30

echo "curl http://${PUBLIC_IP_ADDRESS}"
curl http://${PUBLIC_IP_ADDRESS}
