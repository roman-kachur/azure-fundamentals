$resourceGroupName="task4"
$location="East US"

$resourceExists=az group exists --name $resourceGroupName

if ($resourceExists -eq "false")
{
    Write-Host "Create new resource group "$resourceGroupName
    az group create --location $location --name $resourceGroupName
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Location $location -TemplateFile azuredeploy.json -TemplateParameterFile azuredeploy.parameters.json

az vm extension set --resource-group $resourceGroupName --vm-name "VMtask4" --name CustomScript --publisher Microsoft.Azure.Extensions --settings ./script-config.json
