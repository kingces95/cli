# Region A	        Region B
# East US           West US
# East US 2	        Central US
# North Central US	South Central US
# West US 2	        West Central US
# West US 3	        East US

# https://docs.microsoft.com/en-us/azure/availability-zones/cross-region-replication-azure#azure-cross-region-replication-pairings-for-all-geographies
# regions must be the same or "cross region replication" pairs
ISO_INFRA_LOCATION='westus3'
ISO_HOBO_LOCATION='westus3'
ISO_VM_LOCATION='westus3'

# subscriptions; makes no difference in which subscription HOBO resources are hosted
ISO_INFRA_SUBSCRIPTION="${NIX_FID_SUBSCRIPTION}"
ISO_HOBO_SUBSCRIPTION="${NIX_FID_SUBSCRIPTION}"

# vm
ISO_VM_WIN_IMAGE='MicrosoftWindowsDesktop:Windows-10:21h1-ent:latest'
ISO_VM_USER='azureuser'
ISO_VM_PASSWORD="$(fd-secret-azure-password)"

# named resources
ISO_PREFIX="iso-${NIX_USER}-${NIX_MY_ENV_ID?}"
ISO_PREFIX_S="iso${NIX_USER}${NIX_MY_ENV_ID?}"

# infrastructure named resources
ISO_INFRA_PREFIX="${ISO_PREFIX}-infra"
ISO_INFRA_PREFIX_S="${ISO_PREFIX_S}infra"
ISO_INFRA_RG="${ISO_PREFIX}-rg" # kiss
ISO_INFRA_VNET="${ISO_INFRA_PREFIX}-vnet"
ISO_INFRA_VNET_RANGE='10.80.0.0/19'
ISO_INFRA_BASTION_IP="${ISO_INFRA_PREFIX}-bastion-ip"
ISO_INFRA_BASTION_SUBNET_PREFIXES='10.80.0.0/27'
ISO_INFRA_BASTION_SUBNET='AzureBastionSubnet'
ISO_INFRA_BASTION="${ISO_INFRA_PREFIX}-bastion"
ISO_INFRA_SUBNET='default'
ISO_INFRA_SUBNET_PREFIXES='10.80.1.0/27'
ISO_INFRA_WIN="iso-${NIX_USER:0:2}-${NIX_MY_ENV_ID?}-win"

# hobo named resources
ISO_HOBO_PREFIX="${ISO_PREFIX}-hobo"
ISO_HOBO_PREFIX_S="${ISO_PREFIX_S}hobo"
ISO_HOBO_RG="${ISO_PREFIX}-rg" # kiss
ISO_HOBO_SUBNET="default"
ISO_HOBO_STORAGE_SE="${ISO_HOBO_PREFIX_S}se"
ISO_HOBO_STORAGE_SE_SHARE="share"
ISO_HOBO_KEYVAULT_SE="${ISO_HOBO_PREFIX}-kv"

# create infra groups
az group create \
    --name ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_LOCATION}

# create hobo groups
az group create \
    --name ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --location ${ISO_HOBO_LOCATION}

# create infra vnets
az network vnet create \
    --name ${ISO_INFRA_VNET} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --resource-group ${ISO_INFRA_RG} \
    --location ${ISO_INFRA_LOCATION} \
    --address-prefix ${ISO_INFRA_VNET_RANGE}

# create infra bastion subnet
az network vnet subnet create \
    --name "${ISO_INFRA_BASTION_SUBNET}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_VNET}" \
    --address-prefixes "${ISO_INFRA_BASTION_SUBNET_PREFIXES}"

# create infra default subnet
az network vnet subnet create \
    --name "${ISO_INFRA_SUBNET}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_VNET}" \
    --address-prefixes "${ISO_INFRA_SUBNET_PREFIXES}"

# get infra default subnet id
ISO_INFRA_SUBNET_ID=$(
    az network vnet subnet show \
        --name "${ISO_INFRA_SUBNET}" \
        --resource-group ${ISO_INFRA_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --vnet-name "${ISO_INFRA_VNET}" \
        --query id --output tsv
)

# create infra VM
az vm create \
    --name "${ISO_INFRA_WIN}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location "westus3" \
    --image "${ISO_VM_WIN_IMAGE}" \
    --public-ip-sku "Standard" \
    --public-ip-address "" \
    --subnet "${ISO_INFRA_SUBNET_ID?}" \
    --admin-username "${ISO_VM_USER}" \
    --admin-password "${ISO_VM_PASSWORD}" \
    --tags subgroup=win

# create infra bastion public-ip
az network public-ip create \
    --name "${ISO_INFRA_BASTION_IP}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_LOCATION} \
    --sku Standard

# create infra bastion
az network bastion create \
    --name "${ISO_INFRA_BASTION}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_LOCATION} \
    --public-ip-address "${ISO_INFRA_BASTION_IP}" \
    --vnet-name "${ISO_INFRA_VNET}"

# az network vnet list-endpoint-services
# https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-restrict-network-access-to-resources-cli

# create hobo storage accounts
az storage account create \
    --name "${ISO_HOBO_STORAGE_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --location ${ISO_HOBO_LOCATION}

# create shares in storage accounts
az storage share create \
    --name "${ISO_HOBO_STORAGE_SE_SHARE}" \
    --account-name "${ISO_HOBO_STORAGE_SE}" \
    --subscription ${ISO_HOBO_SUBSCRIPTION}

az keyvault create \
    --name "${ISO_HOBO_KEYVAULT_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --location ${ISO_HOBO_LOCATION}

# enable service-endpoint on subnet <-> services
az network vnet subnet update \
    --name "${ISO_INFRA_SUBNET}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_VNET}" \
    --service-endpoints \
        Microsoft.Storage \
        Microsoft.KeyVault

# deny traffic to hobo storage
az storage account update \
    --name "${ISO_HOBO_STORAGE_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --default-action Deny

# whitelist traffic to hobo storage
az storage account network-rule add \
    --account-name "${ISO_HOBO_STORAGE_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --subnet "${ISO_INFRA_SUBNET_ID?}"        

# deny traffic to hobo keyvault
az keyvault update \
    --name "${ISO_HOBO_KEYVAULT_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --default-action Deny

# whitelist traffic to hobo keyvault
az keyvault network-rule add \
    --name "${ISO_HOBO_KEYVAULT_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION} \
    --subnet "${ISO_INFRA_SUBNET_ID?}"  

# reflect on hobo vnet, storage, and keyvault
az network vnet subnet show \
    --name "${ISO_INFRA_SUBNET}" \
    --resource-group ${ISO_INFRA_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_VNET}"
az storage account show \
    --name "${ISO_HOBO_STORAGE_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION}
az keyvault show \
    --name "${ISO_HOBO_KEYVAULT_SE}" \
    --resource-group ${ISO_HOBO_RG} \
    --subscription ${ISO_HOBO_SUBSCRIPTION}

# cleanup
az resource delete \
    --ids /subscriptions/${ISO_INFRA_SUBSCRIPTION}/resourceGroups/${ISO_INFRA_RG}
az resource delete \
    --ids /subscriptions/${NIX_HOBO_SUBSCRIPTION}/resourceGroups/${ISO_HOBO_RG}
    