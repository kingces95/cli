declare -g PL_PREFIX="nix-${NIX_USER}-${NIX_FID_TAG}-${NIX_MY_ENV_ID}-pl"
declare -g PL_GROUP="${PL_PREFIX}-rg"
declare -g PL_LOCATION=eastus
declare -g PL_VNET="${PL_PREFIX}-vnet"
declare -g PL_VNET_ADDRESS_PREFIXES=10.0.0.0/16
declare -g PL_VNET_SUBNET=backend
declare -g PL_VNET_SUBNET_PREFIXES=10.0.0.0/24
declare -g PL_BASTION_SUBNET=AzureBastionSubnet
declare -g PL_BASTION_SUBNET_PREFIXES=10.0.1.0/27
declare -g PL_BASTION_IP=bastion
declare -g PL_BASTION=bastion
declare -g PL_WEBAPP="${PL_PREFIX}-web-app"
declare -g PL_WEBAPP_PUB="${PL_PREFIX}-web-app-pub"
declare -g PL_PLAN="${PL_PREFIX}-hosting-plan"
declare -g PL_PLAN_PUB="${PL_PREFIX}-hosting-plan-pub"
declare -g PL_CONNECTION=connection
declare -g PL_DNS_ENDPOINT=private-endpoint
declare -g PL_DNS_ZONE='privatelink.azurewebsites.net'
declare -g PL_DNS_ZONE_LINK='MyDNSLink'
declare -g PL_DNS_ZONE_GROUP='MyZoneGroup'
declare -g PL_VM="${PL_PREFIX}-linux"
declare -g PL_VM_WIN="nix-${NIX_USER:0:2}-${NIX_MY_ENV_ID}-win"
declare -g PL_VM_USER='azureuser'
declare -g PL_VM_PASSWORD="$(fd-secret-azure-password)"

# https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/nix-chrkin-pub-27-pl-rg/overview
# https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/nix-chrkin-pub-27-pl-rg/providers/Microsoft.Web/sites/nix-chrkin-pub-27-pl-web-app/networkingHub

az group create \
    --name "${PL_GROUP}" \
    --location "${PL_LOCATION}"
    
az appservice plan create \
    --name "${PL_WEBAPP_PUB}" \
    --resource-group "${PL_GROUP}" \
    --location "${PL_LOCATION}" \
    --sku P1V2 \
    --number-of-workers 1    

az webapp create \
    --name "${PL_WEBAPP_PUB}" \
    --resource-group "${PL_GROUP}" \
    --plan "${PL_PLAN_PUB}"

az appservice plan create \
    --name "${PL_PLAN}" \
    --resource-group "${PL_GROUP}" \
    --location "${PL_LOCATION}" \
    --sku P1V2 \
    --number-of-workers 1    

az webapp create \
    --name "${PL_WEBAPP}" \
    --resource-group "${PL_GROUP}" \
    --plan "${PL_PLAN}"

az network vnet create \
    --resource-group "${PL_GROUP}" \
    --location "${PL_LOCATION}" \
    --name "${PL_VNET}" \
    --address-prefixes "${PL_VNET_ADDRESS_PREFIXES}" \
    --subnet-name "${PL_VNET_SUBNET}" \
    --subnet-prefixes "${PL_VNET_SUBNET_PREFIXES}"

az network vnet subnet create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_BASTION_SUBNET}" \
    --vnet-name "${PL_VNET}" \
    --address-prefixes "${PL_BASTION_SUBNET_PREFIXES}"

az network public-ip create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_BASTION_IP}" \
    --sku Standard \
    --zone 1 2 3 \
    --location "${PL_LOCATION}"

# Create a private endpoint
ID=$(az webapp list \
    --resource-group "${PL_GROUP}" \
    --query '[].[id]' \
    --output tsv)
echo $ID

az network private-endpoint create \
    --connection-name "${PL_CONNECTION}" \
    --name "${PL_DNS_ENDPOINT}" \
    --private-connection-resource-id "${ID}" \
    --resource-group "${PL_GROUP}" \
    --subnet "${PL_VNET_SUBNET}" \
    --group-id sites \
    --vnet-name "${PL_VNET}" \
    --location "${PL_LOCATION}"

# Register private link with DNS

# DNS Name
az network private-dns zone create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_DNS_ZONE}"

# DNS Name <-> VNet
az network private-dns link vnet create \
    --resource-group "${PL_GROUP}" \
    --zone-name "${PL_DNS_ZONE}" \
    --name "${PL_DNS_ZONE_LINK}" \
    --virtual-network "${PL_VNET}" \
    --registration-enabled false

# DNS Name <-> Private Link
az network private-endpoint dns-zone-group create \
    --resource-group "${PL_GROUP}" \
    --endpoint-name "${PL_DNS_ENDPOINT}" \
    --name "${PL_DNS_ZONE_GROUP}" \
    --private-dns-zone "${PL_DNS_ZONE}" \
    --zone-name webapp

# Create a VM to browse to our website
az vm create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_VM}" \
    --image Debian \
    --public-ip-address "" \
    --vnet-name "${PL_VNET}" \
    --subnet "${PL_VNET_SUBNET}" \
    --admin-username "${PL_VM_USER}" \
    --admin-password "${PL_VM_PASSWORD}" \
    --location "${PL_LOCATION}"

az vm create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_VM_WIN}" \
    --image 'Win2019Datacenter' \
    --public-ip-address "" \
    --vnet-name "${PL_VNET}" \
    --subnet "${PL_VNET_SUBNET}" \
    --admin-username "${PL_VM_USER}" \
    --admin-password "${PL_VM_PASSWORD}" \
    --location "${PL_LOCATION}"
    
# Create a bastion to browse to our website
az network bastion create \
    --resource-group "${PL_GROUP}" \
    --name "${PL_BASTION}" \
    --public-ip-address "${PL_BASTION_IP}" \
    --vnet-name "${PL_VNET}" \
    --location "${PL_LOCATION}"

nslookup mywebapp1979.azurewebsites.net            