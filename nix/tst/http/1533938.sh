fd-login-as-network-administrator
az group create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_CPC_RESOURCE_GROUP}
az network vnet create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_ENV_PREFIX}-myvnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}
az network vnet subnet create \
    --address-prefixes=10.0.0.0/24 \
    --delegations=Microsoft.Fidalgo/networkSettings \
    --name=${NIX_ENV_PREFIX}-mysubnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION} \
    --vnet-name=${NIX_ENV_PREFIX}-myvnet

fd-login-as-administrator
az group create \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin dev-center create \
    --identity-type=SystemAssigned \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo admin devbox-definition create \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --image-reference=id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-mydevcenter/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mydevboxdefinition \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --sku-name=PrivatePreview \
    --subscription=${NIX_FID_SUBSCRIPTION}
    
az fidalgo admin network-setting create \
    --domain-join-type=AzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-myvnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION}

cat-http ./subscriptions/resourceGroups/providers/networksettings/create.json \
    --domain-join-type=HybridAzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-myvnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    | http-curl | cmd | exe | jq
