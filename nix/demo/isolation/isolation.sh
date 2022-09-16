# Region A	        Region B
# East US	            West US
# East US 2	        Central US
# North Central US	South Central US
# West US 2	        West Central US
# West US 3	        East US

ISO_INFRA_0_LOCATION='westus'
ISO_INFRA_1_LOCATION='eastus'
ISO_HOBO_LOCATION='eastus'

ISO_PREFIX="iso-${NIX_USER}-${NIX_MY_ENV_ID?}"
ISO_PREFIX_S="iso${NIX_USER}${NIX_MY_ENV_ID?}"

# infra vnet address ranges
ISO_INFRA_0_VNET_RANGE='10.80.0.0/19'   # ~8k
ISO_INFRA_1_VNET_RANGE='10.80.32.0/19'  # ~8k

# hobo vnet address ranges
ISO_HOBO_0_VNET_RANGE='10.96.0.0/22'    # ~1k
ISO_HOBO_1_VNET_RANGE='10.96.4.0/22'    # ~1k

# vm
ISO_VM_WIN_IMAGE='MicrosoftWindowsDesktop:Windows-10:21h1-ent:latest'
ISO_VM_USER='azureuser'
ISO_VM_PASSWORD="$(fd-secret-azure-password)"

# infrastructure
ISO_INFRA_PREFIX="${ISO_PREFIX}-infra"
ISO_INFRA_PREFIX_S="${ISO_PREFIX_S}infra"
ISO_INFRA_SUBSCRIPTION="${NIX_FID_SUBSCRIPTION}"

ISO_INFRA_0_PREFIX="${ISO_INFRA_PREFIX}-0"
ISO_INFRA_0_PREFIX_S="${ISO_INFRA_PREFIX_S}0"
ISO_INFRA_0_RG="${ISO_INFRA_0_PREFIX}-rg"
ISO_INFRA_0_VNET="${ISO_INFRA_0_PREFIX}-vnet"
ISO_INFRA_0_BASTION_SUBNET='AzureBastionSubnet'
ISO_INFRA_0_BASTION_SUBNET_PREFIXES='10.80.0.0/27'
ISO_INFRA_0_BASTION_IP="${ISO_INFRA_0_PREFIX}-bastion-ip"
ISO_INFRA_0_BASTION="${ISO_INFRA_0_PREFIX}-bastion"
ISO_INFRA_0_SUBNET='default'
ISO_INFRA_0_SUBNET_PREFIXES='10.80.1.0/27'
ISO_INFRA_0_WIN="iso-${NIX_USER:0:2}-${NIX_MY_ENV_ID?}-0-win"

ISO_INFRA_1_PREFIX="${ISO_INFRA_PREFIX}-1"
ISO_INFRA_1_PREFIX_S="${ISO_INFRA_PREFIX_S}1"
ISO_INFRA_1_RG="${ISO_INFRA_1_PREFIX}-rg"
ISO_INFRA_1_VNET="${ISO_INFRA_1_PREFIX}-vnet"
ISO_INFRA_1_BASTION_SUBNET='AzureBastionSubnet'
ISO_INFRA_1_BASTION_SUBNET_PREFIXES='10.80.32.0/27'
ISO_INFRA_1_BASTION_IP="${ISO_INFRA_1_PREFIX}-bastion-ip"
ISO_INFRA_1_BASTION="${ISO_INFRA_1_PREFIX}-bastion"
ISO_INFRA_1_SUBNET='default'
ISO_INFRA_1_SUBNET_PREFIXES='10.80.33.0/27'
ISO_INFRA_1_WIN="iso-${NIX_USER:0:2}-${NIX_MY_ENV_ID?}-1-win"

# hobo
ISO_HOBO_PREFIX="${ISO_PREFIX}-hobo"
ISO_HOBO_PREFIX_S="${ISO_PREFIX_S}hobo"

ISO_HOBO_0_PREFIX="${ISO_HOBO_PREFIX}-0"
ISO_HOBO_0_PREFIX_S="${ISO_HOBO_PREFIX_S}0"
ISO_HOBO_0_SUBSCRIPTION="${NIX_HOBO_SUBSCRIPTION}"
ISO_HOBO_0_RG="${ISO_HOBO_0_PREFIX}-rg"
ISO_HOBO_0_VNET="${ISO_HOBO_0_PREFIX}-vnet"
ISO_HOBO_0_SUBNET="default"
ISO_HOBO_0_STORAGE_PE="${ISO_HOBO_0_PREFIX_S}pe"
ISO_HOBO_0_STORAGE_PE_SHARE="share"
ISO_HOBO_0_STORAGE_SE="${ISO_HOBO_0_PREFIX_S}se"
ISO_HOBO_0_STORAGE_SE_SHARE="share"
ISO_HOBO_0_PRIVATE_ENDPOINT="${ISO_HOBO_0_PREFIX}-pe"
ISO_HOBO_0_PRIVATE_ENDPOINT_NIC="${ISO_HOBO_0_PREFIX}-pe-nic"
ISO_HOBO_0_PRIVATE_ENDPOINT_GROUP_ID='file'
ISO_HOBO_0_KEYVAULT_SE="${ISO_HOBO_0_PREFIX}-kv"

ISO_HOBO_1_PREFIX="${ISO_HOBO_PREFIX}-1"
ISO_HOBO_1_PREFIX_S="${ISO_HOBO_PREFIX_S}1"
ISO_HOBO_1_SUBSCRIPTION="${NIX_HOBO_SUBSCRIPTION}"
ISO_HOBO_1_RG="${ISO_HOBO_1_PREFIX}-rg"
ISO_HOBO_1_VNET="${ISO_HOBO_1_PREFIX}-vnet"
ISO_HOBO_1_SUBNET="default"
ISO_HOBO_1_STORAGE_PE="${ISO_HOBO_1_PREFIX_S}pe"
ISO_HOBO_1_STORAGE_PE_SHARE="share"
ISO_HOBO_1_STORAGE_SE="${ISO_HOBO_1_PREFIX_S}se"
ISO_HOBO_1_STORAGE_SE_SHARE="share"
ISO_HOBO_1_PRIVATE_ENDPOINT="${ISO_HOBO_1_PREFIX}-pe"
ISO_HOBO_1_PRIVATE_ENDPOINT_NIC="${ISO_HOBO_1_PREFIX}-pe-nic"
ISO_HOBO_1_PRIVATE_ENDPOINT_GROUP_ID='file'
ISO_HOBO_1_KEYVAULT_SE="${ISO_HOBO_1_PREFIX}-kv"

# create infra groups
az group create \
    --name ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_0_LOCATION}
az group create \
    --name ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_1_LOCATION}

# create hobo groups
az group create \
    --name ${ISO_HOBO_0_RG} \
    --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
    --location ${ISO_HOBO_LOCATION}
az group create \
    --name ${ISO_HOBO_1_RG} \
    --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
    --location ${ISO_HOBO_LOCATION}

# create infra vnets
az network vnet create \
    --name ${ISO_INFRA_0_VNET} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --resource-group ${ISO_INFRA_0_RG} \
    --location ${ISO_INFRA_0_LOCATION} \
    --address-prefix ${ISO_INFRA_0_VNET_RANGE}
az network vnet create \
    --name ${ISO_INFRA_1_VNET} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --resource-group ${ISO_INFRA_1_RG} \
    --location ${ISO_INFRA_1_LOCATION} \
    --address-prefix ${ISO_INFRA_1_VNET_RANGE}

# create bastion subnet
az network vnet subnet create \
    --name "${ISO_INFRA_0_BASTION_SUBNET}" \
    --resource-group ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_0_VNET}" \
    --address-prefixes "${ISO_INFRA_0_BASTION_SUBNET_PREFIXES}"
az network vnet subnet create \
    --name "${ISO_INFRA_1_BASTION_SUBNET}" \
    --resource-group ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_1_VNET}" \
    --address-prefixes "${ISO_INFRA_1_BASTION_SUBNET_PREFIXES}"

# create bastion public-ip
az network public-ip create \
    --name "${ISO_INFRA_0_BASTION_IP}" \
    --resource-group ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_0_LOCATION} \
    --sku Standard
az network public-ip create \
    --name "${ISO_INFRA_1_BASTION_IP}" \
    --resource-group ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_1_LOCATION} \
    --sku Standard

# create bastion
az network bastion create \
    --name "${ISO_INFRA_0_BASTION}" \
    --resource-group ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_0_LOCATION} \
    --public-ip-address "${ISO_INFRA_0_BASTION_IP}" \
    --vnet-name "${ISO_INFRA_0_VNET}"
az network bastion create \
    --name "${ISO_INFRA_1_BASTION}" \
    --resource-group ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_1_LOCATION} \
    --public-ip-address "${ISO_INFRA_1_BASTION_IP}" \
    --vnet-name "${ISO_INFRA_1_VNET}"

# create default subnet
az network vnet subnet create \
    --name "${ISO_INFRA_0_SUBNET}" \
    --resource-group ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_0_VNET}" \
    --address-prefixes "${ISO_INFRA_0_SUBNET_PREFIXES}"
az network vnet subnet create \
    --name "${ISO_INFRA_1_SUBNET}" \
    --resource-group ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --vnet-name "${ISO_INFRA_1_VNET}" \
    --address-prefixes "${ISO_INFRA_1_SUBNET_PREFIXES}"

# get default subnet id
ISO_INFRA_0_SUBNET_ID=$(
    az network vnet subnet show \
        --name "${ISO_INFRA_0_SUBNET}" \
        --resource-group ${ISO_INFRA_0_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --vnet-name "${ISO_INFRA_0_VNET}" \
        --query id --output tsv
)
ISO_INFRA_1_SUBNET_ID=$(
    az network vnet subnet show \
        --name "${ISO_INFRA_1_SUBNET}" \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --vnet-name "${ISO_INFRA_1_VNET}" \
        --query id --output tsv
)

# create VM
az vm create \
    --name "${ISO_INFRA_0_WIN}" \
    --resource-group ${ISO_INFRA_0_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location 'eastus' \
    --image "${ISO_VM_WIN_IMAGE}" \
    --public-ip-sku "Standard" \
    --public-ip-address "" \
    --subnet "${ISO_INFRA_0_SUBNET_ID?}" \
    --admin-username "${ISO_VM_USER}" \
    --admin-password "${ISO_VM_PASSWORD}" \
    --tags subgroup=win
az vm create \
    --name "${ISO_INFRA_1_WIN}" \
    --resource-group ${ISO_INFRA_1_RG} \
    --subscription ${ISO_INFRA_SUBSCRIPTION} \
    --location ${ISO_INFRA_1_LOCATION} \
    --image "${ISO_VM_WIN_IMAGE}" \
    --public-ip-sku "Standard" \
    --public-ip-address "" \
    --subnet "${ISO_INFRA_1_SUBNET_ID?}" \
    --admin-username "${ISO_VM_USER}" \
    --admin-password "${ISO_VM_PASSWORD}" \
    --tags subgroup=win

# create hobo vnets
az network vnet create \
    --name ${ISO_HOBO_0_VNET} \
    --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
    --resource-group ${ISO_HOBO_0_RG} \
    --location ${ISO_HOBO_LOCATION} \
    --address-prefix ${ISO_HOBO_0_VNET_RANGE} \
    --subnet-name ${ISO_HOBO_0_SUBNET} \
    --subnet-prefixes ${ISO_HOBO_0_VNET_RANGE}
az network vnet create \
    --name ${ISO_HOBO_1_VNET} \
    --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
    --resource-group ${ISO_HOBO_1_RG} \
    --location ${ISO_HOBO_LOCATION} \
    --address-prefix ${ISO_HOBO_1_VNET_RANGE} \
    --subnet-name ${ISO_HOBO_1_SUBNET} \
    --subnet-prefixes ${ISO_HOBO_1_VNET_RANGE}

# get infra vnet ids
ISO_INFRA_0_VNET_ID=$(
    az network vnet show \
        --name ${ISO_INFRA_0_VNET} \
        --resource-group ${ISO_INFRA_0_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --query id --out tsv
)
ISO_INFRA_1_VNET_ID=$(
    az network vnet show \
        --name ${ISO_INFRA_1_VNET} \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --query id --out tsv
)

# get hobo vnet ids
ISO_HOBO_0_VNET_ID=$(
    az network vnet show \
        --name ${ISO_HOBO_0_VNET} \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --query id --out tsv
)
ISO_HOBO_1_VNET_ID=$(
    az network vnet show \
        --name ${ISO_HOBO_1_VNET} \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --query id --out tsv
)

peerings() {

    # infra-0 <-> hobo 0
    az network vnet peering create \
        --name infra-0-hobo-0 \
        --vnet-name ${ISO_INFRA_0_VNET} \
        --resource-group ${ISO_INFRA_0_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --remote-vnet ${ISO_HOBO_0_VNET_ID?} \
        --allow-vnet-access
    az network vnet peering create \
        --name hobo-0-infra-0 \
        --vnet-name ${ISO_HOBO_0_VNET} \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --remote-vnet ${ISO_INFRA_0_VNET_ID?} \
        --allow-vnet-access

    # infra-0 <-> hobo 1
    az network vnet peering create \
        --name infra-0-hobo-1 \
        --vnet-name ${ISO_INFRA_0_VNET} \
        --resource-group ${ISO_INFRA_0_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --remote-vnet ${ISO_HOBO_1_VNET_ID?} \
        --allow-vnet-access
    az network vnet peering create \
        --name hobo-1-infra-0 \
        --vnet-name ${ISO_HOBO_1_VNET} \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --remote-vnet ${ISO_INFRA_0_VNET_ID?} \
        --allow-vnet-access

    # infra-1 <-> hobo 0
    az network vnet peering create \
        --name infra-1-hobo-0 \
        --vnet-name ${ISO_INFRA_1_VNET} \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --remote-vnet ${ISO_HOBO_0_VNET_ID?} \
        --allow-vnet-access
    az network vnet peering create \
        --name hobo-0-infra-1 \
        --vnet-name ${ISO_HOBO_0_VNET} \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --remote-vnet ${ISO_INFRA_1_VNET_ID?} \
        --allow-vnet-access

    # infra-1 <-> hobo 1
    az network vnet peering create \
        --name infra-1-hobo-1 \
        --vnet-name ${ISO_INFRA_1_VNET} \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --remote-vnet ${ISO_HOBO_1_VNET_ID?} \
        --allow-vnet-access
    az network vnet peering create \
        --name hobo-1-infra-1 \
        --vnet-name ${ISO_HOBO_1_VNET} \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --remote-vnet ${ISO_INFRA_1_VNET_ID?} \
        --allow-vnet-access        
}
    
service_endpoint() {
    # az network vnet list-endpoint-services
    # https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-restrict-network-access-to-resources-cli

    # create storage accounts
    az storage account create \
        --name "${ISO_HOBO_0_STORAGE_SE}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}
    az storage account create \
        --name "${ISO_HOBO_1_STORAGE_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}

    # create shares in storage accounts
    az storage share create \
        --name "${ISO_HOBO_0_STORAGE_SE_SHARE}" \
        --account-name "${ISO_HOBO_0_STORAGE_SE}" \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION}
    az storage share create \
        --name "${ISO_HOBO_1_STORAGE_SE_SHARE}" \
        --account-name "${ISO_HOBO_1_STORAGE_SE}" \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION}

    # get storage ids
    ISO_HOBO_0_STORAGE_SE_ID=$(
        az storage account show \
            --name "${ISO_HOBO_0_STORAGE_SE}" \
            --resource-group ${ISO_HOBO_0_RG} \
            --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
            --query id --output tsv
    )
    ISO_HOBO_1_STORAGE_SE_ID=$(
        az storage account show \
            --name "${ISO_HOBO_1_STORAGE_SE}" \
            --resource-group ${ISO_HOBO_1_RG} \
            --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
            --query id --output tsv
    )

    az keyvault create \
        --name "${ISO_HOBO_0_KEYVAULT_SE}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}
    az keyvault create \
        --name "${ISO_HOBO_1_KEYVAULT_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}

    # enable service-endpoint on subnet <-> services
    az network vnet subnet update \
        --name "${ISO_INFRA_1_SUBNET}" \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --vnet-name "${ISO_INFRA_1_VNET}" \
        --service-endpoints \
            Microsoft.Storage \
            Microsoft.KeyVault

    # deny hobo storage access except from infra subnet
    az storage account update \
        --name "${ISO_HOBO_1_STORAGE_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --default-action Deny
    az storage account network-rule add \
        --account-name "${ISO_HOBO_1_STORAGE_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --subnet "${ISO_INFRA_1_SUBNET_ID?}"        

    # deny hobo keyvault access except from infra subnet
    az keyvault update \
        --name "${ISO_HOBO_1_KEYVAULT_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --default-action Deny
    az keyvault network-rule add \
        --name "${ISO_HOBO_1_KEYVAULT_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --subnet "${ISO_INFRA_1_SUBNET_ID?}"  

    # reflect on hobo vnet, storage, and keyvault
    az network vnet subnet show \
        --name "${ISO_INFRA_1_SUBNET}" \
        --resource-group ${ISO_INFRA_1_RG} \
        --subscription ${ISO_INFRA_SUBSCRIPTION} \
        --vnet-name "${ISO_INFRA_1_VNET}"
    az storage account show \
        --name "${ISO_HOBO_1_STORAGE_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION}
    az keyvault show \
        --name "${ISO_HOBO_1_KEYVAULT_SE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION}
}

private_endpoint() {
    # create storage accounts
    az storage account create \
        --name "${ISO_HOBO_0_STORAGE_PE}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}
    az storage account create \
        --name "${ISO_HOBO_1_STORAGE_PE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION}

    # create shares in storage accounts
    az storage share create \
        --name "${ISO_HOBO_0_STORAGE_PE_SHARE}" \
        --account-name "${ISO_HOBO_0_STORAGE_PE}" \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION}
    az storage share create \
        --name "${ISO_HOBO_1_STORAGE_PE_SHARE}" \
        --account-name "${ISO_HOBO_1_STORAGE_PE}" \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION}

    # get storage ids
    ISO_HOBO_0_STORAGE_PE_ID=$(
        az storage account show \
            --name "${ISO_HOBO_0_STORAGE_PE}" \
            --resource-group ${ISO_HOBO_0_RG} \
            --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
            --query id --output tsv
    )
    ISO_HOBO_1_STORAGE_PE_ID=$(
        az storage account show \
            --name "${ISO_HOBO_1_STORAGE_PE}" \
            --resource-group ${ISO_HOBO_1_RG} \
            --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
            --query id --output tsv
    )

    # get hobo subnet ids
    ISO_HOBO_0_SUBNET_ID=$(
        az network vnet subnet show \
            --name "${ISO_HOBO_0_SUBNET}" \
            --resource-group ${ISO_HOBO_0_RG} \
            --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
            --vnet-name "${ISO_HOBO_0_VNET}" \
            --query id --output tsv
    )
    ISO_HOBO_1_SUBNET_ID=$(
        az network vnet subnet show \
            --name "${ISO_HOBO_1_SUBNET}" \
            --resource-group ${ISO_HOBO_1_RG} \
            --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
            --vnet-name "${ISO_HOBO_1_VNET}" \
            --query id --output tsv
    )

    # create private links
    az network private-endpoint create \
        --name "${ISO_HOBO_0_PRIVATE_ENDPOINT}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION} \
        --connection-name "${ISO_HOBO_0_PRIVATE_ENDPOINT}" \
        --nic-name "${ISO_HOBO_0_PRIVATE_ENDPOINT_NIC}" \
        --subnet "${ISO_HOBO_0_SUBNET_ID?}" \
        --private-connection-resource-id "${ISO_HOBO_0_STORAGE_PE_ID?}" \
        --group-id "${ISO_HOBO_0_PRIVATE_ENDPOINT_GROUP_ID?}" 
    az network private-endpoint create \
        --name "${ISO_HOBO_1_PRIVATE_ENDPOINT}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --location ${ISO_HOBO_LOCATION} \
        --connection-name "${ISO_HOBO_1_PRIVATE_ENDPOINT}" \
        --nic-name "${ISO_HOBO_1_PRIVATE_ENDPOINT_NIC}" \
        --subnet "${ISO_HOBO_1_SUBNET_ID?}" \
        --private-connection-resource-id "${ISO_HOBO_1_STORAGE_PE_ID?}" \
        --group-id "${ISO_HOBO_1_PRIVATE_ENDPOINT_GROUP_ID?}" 

    ISO_DNS_ZONE='privatelink.devbox.net'
    ISO_HOBO_0_DNS_ZONE_LINK='hobo0'
    ISO_HOBO_1_DNS_ZONE_LINK='hobo1'

    # create private dns zone
    az network private-dns zone create \
        --name "${ISO_DNS_ZONE}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION}
    az network private-dns zone create \
        --name "${ISO_DNS_ZONE}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION}

    # attach private dns zone to vnets
    az network private-dns link vnet create \
        --name "${ISO_HOBO_0_DNS_ZONE_LINK}" \
        --resource-group ${ISO_HOBO_0_RG} \
        --subscription ${ISO_HOBO_0_SUBSCRIPTION} \
        --zone-name "${ISO_DNS_ZONE}" \
        --virtual-network "${ISO_HOBO_0_VNET_ID?}" \
        --registration-enabled false
    az network private-dns link vnet create \
        --name "${ISO_HOBO_1_DNS_ZONE_LINK}" \
        --resource-group ${ISO_HOBO_1_RG} \
        --subscription ${ISO_HOBO_1_SUBSCRIPTION} \
        --zone-name "${ISO_DNS_ZONE}" \
        --virtual-network "${ISO_HOBO_1_VNET_ID?}" \
        --registration-enabled false        
}

# cleanup
az resource delete \
    --ids /subscriptions/${ISO_INFRA_SUBSCRIPTION}/resourceGroups/${ISO_INFRA_0_RG}
az resource delete \
    --ids /subscriptions/${ISO_INFRA_SUBSCRIPTION}/resourceGroups/${ISO_INFRA_1_RG}
az resource delete \
    --ids /subscriptions/${NIX_HOBO_SUBSCRIPTION}/resourceGroups/${ISO_HOBO_0_RG}
az resource delete \
    --ids /subscriptions/${NIX_HOBO_SUBSCRIPTION}/resourceGroups/${ISO_HOBO_1_RG}
    