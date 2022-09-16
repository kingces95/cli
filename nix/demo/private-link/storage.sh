# https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-storage-portal
# https://portal.azure.com/#@fidalgoppe010.onmicrosoft.com/resource/subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/nix-chrkin-ppe-31-pl-rg/overview
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-private-link

readonly PL_PREFIX="${NIX_ENV_PREFIX}-pl"

# network
readonly PL_VNET="${PL_PREFIX}-vnet"
readonly PL_VNET_ADDRESS_PREFIXES=10.0.0.0/16
readonly PL_VNET_SUBNET='default'
readonly PL_VNET_SUBNET_PREFIXES=10.0.0.0/24

# bastion
readonly PL_BASTION_SUBNET='AzureBastionSubnet'
readonly PL_BASTION_SUBNET_PREFIXES='10.0.1.0/27'
readonly PL_BASTION_IP='bastion-ip'
readonly PL_BASTION='bastion'

# compute
readonly PL_VM_UNIX="${PL_PREFIX}-linux"
readonly PL_VM_UNIX_IMAGE='Debian'
readonly PL_VM_WIN="nix-${NIX_USER:0:2}-${NIX_MY_ENV_ID}-win"
readonly PL_VM_WIN_IMAGE='MicrosoftWindowsDesktop:Windows-10:21h1-ent:latest'
readonly PL_VM_USER='azureuser'
readonly PL_VM_PASSWORD="$(fd-secret-azure-password)"

# storage
readonly PL_STORAGE="nix${NIX_USER}${NIX_FID_TAG}${NIX_MY_ENV_ID}plsa"
readonly PL_STORAGE_SHARE="my-share"

# endpoint
readonly PL_ENDPOINT="${PL_PREFIX}-ep"
readonly PL_ENDPOINT_NIC="${PL_ENDPOINT}-nic"
readonly PL_ENDPOINT_GROUP_ID='file'

# DNS
readonly PL_DNS_ZONE='privatelink.azurewebsites.net'
readonly PL_DNS_ZONE_LINK='MyZoneLink'
readonly PL_DNS_ZONE_GROUP='MyZoneGroup'

# azure
export AZURE_DEFAULTS_GROUP="${PL_PREFIX}-rg"
export AZURE_DEFAULTS_LOCATION='centraluseuap'

az group create \
    --name "${AZURE_DEFAULTS_GROUP}"
    
# create Network
az network vnet create \
    --name "${PL_VNET}" \
    --address-prefixes "${PL_VNET_ADDRESS_PREFIXES}" \
    --subnet-name "${PL_VNET_SUBNET}" \
    --subnet-prefixes "${PL_VNET_SUBNET_PREFIXES}"

az network vnet subnet show \
    --name "${PL_VNET_SUBNET}" \
    --vnet-name "${PL_VNET}"

readonly PL_VNET_SUBNET_ID=$(
    az network vnet subnet show \
        --name "${PL_VNET_SUBNET}" \
        --vnet-name "${PL_VNET}" \
        --query id --output tsv
)

# create Bastion
az network vnet subnet create \
    --name "${PL_BASTION_SUBNET}" \
    --vnet-name "${PL_VNET}" \
    --address-prefixes "${PL_BASTION_SUBNET_PREFIXES}"

az network public-ip create \
    --name "${PL_BASTION_IP}" \
    --sku Standard \
    --zone 1 2

az network bastion create \
    --name "${PL_BASTION}" \
    --public-ip-address "${PL_BASTION_IP}" \
    --vnet-name "${PL_VNET}"

# create VM
az vm create \
    --name "${PL_VM_UNIX}" \
    --image "${PL_VM_UNIX_IMAGE}" \
    --public-ip-address "" \
    --subnet "${PL_VNET_SUBNET_ID}" \
    --admin-username "${PL_VM_USER}" \
    --admin-password "${PL_VM_PASSWORD}"

az vm create \
    --name "${PL_VM_WIN}" \
    --image "${PL_VM_WIN_IMAGE}" \
    --public-ip-address "" \
    --subnet "${PL_VNET_SUBNET_ID}" \
    --admin-username "${PL_VM_USER}" \
    --admin-password "${PL_VM_PASSWORD}"

# create Storage
az storage account create \
    --name "${PL_STORAGE}"

readonly PL_STORAGE_ID=$(
    az storage account create \
        --name "${PL_STORAGE}" \
        --query id --output tsv
)

az storage share create \
    --name "${PL_STORAGE_SHARE}" \
    --account-name "${PL_STORAGE}" 

# allow public access for DevCenter infrastructure
# az storage account update \
#     --name "${PL_STORAGE}" \
#     --public-network-access Disabled

# create private endpoint
az network private-endpoint create \
    --name "${PL_ENDPOINT}" \
    --connection-name "${PL_ENDPOINT}" \
    --nic-name "${PL_ENDPOINT_NIC}" \
    --subnet "${PL_VNET_SUBNET_ID}" \
    --private-connection-resource-id "${PL_STORAGE_ID}" \
    --group-id "${PL_ENDPOINT_GROUP_ID}" 

# register private link with DNS

# resolution scope
az network private-dns zone create \
    --name "${PL_DNS_ZONE}"

# resolution scope includes DNS requests from vNet
az network private-dns link vnet create \
    --name "${PL_DNS_ZONE_LINK}" \
    --zone-name "${PL_DNS_ZONE}" \
    --virtual-network "${PL_VNET}" \
    --registration-enabled false

# resolve resources attached to private endpoint to private endpoint IP
az network private-endpoint dns-zone-group create \
    --name "${PL_DNS_ZONE_GROUP}" \
    --endpoint-name "${PL_ENDPOINT}" \
    --private-dns-zone "${PL_DNS_ZONE}" \
    --zone-name "${PL_DNS_ZONE}"

cleanup() {
    az resource delete --id "${PL_VNET_ID}"         
    az resource delete --id "${PL_VNET_SUBNET_ID}"         
    az resource delete --id "${PL_BASTION_SUBNET_ID}"         
    az resource delete --id "${PL_BASTION_IP_ID}" 
    az resource delete --id "${PL_BASTION_ID}"         
    az resource delete --id "${PL_ENDPOINT_ID}"         
    az resource delete --id "${PL_STORAGE_ID}"         
    az resource delete --id "${PL_VM_WIN_ID}"         
    az resource delete --id "${PL_VM_UNIX_ID}"         
}

# https://docs.microsoft.com/en-us/azure/vs-azure-tools-storage-manage-with-storage-explorer?tabs=windows&toc=/azure/storage/blobs/toc.json
# nslookup <storage-account-name>.blob.core.windows.net