NIX_SUBNET_AZURE_FIREWALL=AzureFirewallSubnet
NIX_SUBNET_AZURE_BASTION=AzureBastionSubnet
NIX_SUBNET_GATEWAY=GatewaySubnet

(

    set -e
    fd-login-as-network-administrator
    az group create \
        --name ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --location ${NIX_CPC_LOCATION}
    az network vnet create \
        --name ${NIX_ENV_PREFIX}-my-vnet \
        --resource-group ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --location ${NIX_CPC_LOCATION}
    az network vnet subnet create \
        --name ${NIX_SUBNET_AZURE_FIREWALL?} \
        --vnet-name ${NIX_ENV_PREFIX}-my-vnet \
        --resource-group ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes 10.0.2.0/24 \
        --delegations Microsoft.Fidalgo/networkSettings
    az network vnet subnet create \
        --name ${NIX_SUBNET_AZURE_BASTION?} \
        --vnet-name ${NIX_ENV_PREFIX}-my-vnet \
        --resource-group ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes 10.0.0.0/24 \
        --delegations Microsoft.Fidalgo/networkSettings
    az network vnet subnet create \
        --name ${NIX_SUBNET_GATEWAY?} \
        --vnet-name ${NIX_ENV_PREFIX}-my-vnet \
        --resource-group ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes 10.0.1.0/24 \
        --delegations Microsoft.Fidalgo/networkSettings
)
(
    set -e
    fd-login-as-administrator
    az group create \
        --name ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --location ${NIX_FID_LOCATION}

    # AzureFirewallSubnet
    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_SUBNET_AZURE_FIREWALL}
  
    # AzureBastionSubnet
    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_SUBNET_AZURE_BASTION}
  
    # GatewaySubnet
    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_SUBNET_GATEWAY}
)