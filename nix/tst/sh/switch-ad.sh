(
    set -e
    fd-login-as-developer # ensure developer persona created
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
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET}
    az devcenter admin network-connection create \
        --name ${NIX_ENV_PREFIX}-my-hybrid-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type HybridAzureADJoin \
        --domain-name "${NIX_CPC_DOMAIN_NAME}" \
        --domain-password "$(fd-secret-azure-password)" \
        --domain-username "${NIX_CPC_DOMAIN_JOIN_ACCOUNT}" \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET}
    az devcenter admin attached-network create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
    az devcenter admin attached-network create \
        --name ${NIX_ENV_PREFIX}-my-hybrid-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-hybrid-ad-network-connection
    az devcenter admin devbox-definition create \
        --name ${NIX_ENV_PREFIX}-my-devbox-definition \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --image-reference \
            id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
        --location ${NIX_FID_LOCATION} \
        --os-storage-type ssd_1024gb \
        --sku name=general_a_8c32gb_v1
    az devcenter admin project create \
        --name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc \
        --location ${NIX_FID_LOCATION}
    az role assignment create \
        --assignee ${NIX_ENV_PERSONA_DEVELOPER} \
        --role "DevCenter Dev Box User" \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project \
        --subscription ${NIX_FID_SUBSCRIPTION}

    az devcenter admin network-connection show \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin network-connection show-health-detail \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin network-connection run-health-check \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin network-connection show \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}

    az devcenter admin pool create \
        --name ${NIX_ENV_PREFIX}-my-pool \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --devbox-definition-name ${NIX_ENV_PREFIX}-my-devbox-definition \
        --location "${NIX_FID_LOCATION}" \
        --local-administrator Enabled \
        --license-type Windows_Client \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network
    az devcenter admin pool update \
        --name ${NIX_ENV_PREFIX}-my-pool \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-name ${NIX_ENV_PREFIX}-my-hybrid-ad-attached-network \
        --debug

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project/pools/${NIX_ENV_PREFIX}-my-pool
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devboxdefinitions/${NIX_ENV_PREFIX}-my-devbox-definition
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/attachednetworks/${NIX_ENV_PREFIX}-my-hybrid-ad-attached-network
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/attachednetworks/${NIX_ENV_PREFIX}-my-azure-ad-attached-network
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-hybrid-ad-network-connection
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}
)
