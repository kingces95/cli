(
    set -e
    fd-login-as-administrator

    az group create \
        --name ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --location ${NIX_FID_LOCATION}
    az devcenter admin devcenter create \
        --name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --identity-type SystemAssigned \
        --location ${NIX_FID_LOCATION}
    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection-0 \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET}
    az devcenter admin attached-network create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection-0
    az devcenter admin attached-network update \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection-0

    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection-1 \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET}
    az devcenter admin attached-network update \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection-1

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/attachednetworks/${NIX_ENV_PREFIX}-my-azure-ad-attached-network
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection-0
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection-1
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}
)
