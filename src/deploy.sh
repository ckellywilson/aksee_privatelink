#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Variables
# Get the Azure AD signed-in user ID
echo "Getting the Azure AD signed-id user ID..."
adminUserId=$(az ad signed-in-user show --query "id" --output tsv)
echo "adminUserId: $adminUserId"

prefix="aksee"
echo "prefix: $prefix"

# Generate SSH key
echo "Generating SSH key..."
ssh-keygen -t rsa -b 4096 -f ~/.ssh/${prefix}-sh -N ""

keyData=$(cat ~/.ssh/${prefix}-sh.pub)
location="centralus"
deploymentName="${prefix}-deployment"

# Deploy AKS cluster using Bicep template
az deployment sub create --name $deploymentName \
    --location $location \
    --parameters location="$location" \
    --parameters keyData="$keyData" \
    --parameters prefix="$prefix" \
    --template-file ./infra/main.bicep


echo "----------------------- Get VM Outputs ----------------------------"
# Get vm outputs
echo "Get vm outputs..."
VM_NAME=$(az deployment sub show --name $deploymentName --query properties.outputs.vmName.value -o tsv)
ADMIN_USERNAME=$(az deployment sub show --name $deploymentName --query properties.outputs.adminUsername.value -o tsv)
RG_NAME=$(az deployment sub show --name $deploymentName --query properties.outputs.rgName.value -o tsv)

echo "----------------------- Login to vm  ----------------------------"
# Login to vm
echo "Login to vm..."
ssh -i ~/.ssh/$prefix-sh $ADMIN_USERNAME@$(az vm show -d --resource-group $RG_NAME --name $VM_NAME --query publicIps -o tsv)