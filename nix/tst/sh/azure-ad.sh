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
        --name ${NIX_ENV_PREFIX}-my-subnet \
        --vnet-name ${NIX_ENV_PREFIX}-my-vnet \
        --resource-group ${NIX_CPC_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes 10.0.0.0/24 \
        --delegations Microsoft.Fidalgo/networkSettings
)
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
        --name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --domain-join-type AzureADJoin \
        --location ${NIX_FID_LOCATION} \
        --subnet-id /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-my-subnet
    az devcenter admin attached-network create \
        --name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
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

    az devcenter admin network-connection show-health-detail \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    # az devcenter admin network-connection run-health-check \
    #     --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-network-connection \
    #     --resource-group ${NIX_FID_RESOURCE_GROUP} \
    #     --subscription ${NIX_FID_SUBSCRIPTION}

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

    az devcenter admin pool show \
        --name ${NIX_ENV_PREFIX}-my-pool \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
)
(
    set -e
    fd-login-as-developer
    az devcenter dev dev-box create \
        --name ${NIX_ENV_PREFIX}-my-vm-0 \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${NIX_ENV_PREFIX}-dc \
        --pool-name ${NIX_ENV_PREFIX}-my-pool \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id) --debug
        #--fidalgo-dns-suffix "${NIX_FID_DNS_SUFFIX}" \
    az devcenter dev dev-box show \
        --name ${NIX_ENV_PREFIX}-my-vm \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${NIX_ENV_PREFIX}-dc \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id)
    az devcenter dev dev-box delete \
        --dev-box-name ${NIX_ENV_PREFIX}-my-vm \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${NIX_ENV_PREFIX}-dc \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id) \
        --yes

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project/virtualmachine/${NIX_ENV_PREFIX}-my-vm \
        --verbose
)
(
    set -e
    fd-login-as-administrator
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project/pools/${NIX_ENV_PREFIX}-my-pool
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project
    
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devboxdefinitions/${NIX_ENV_PREFIX}-my-devbox-definition
    # Resource type devboxdefinitions not found.

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/attachednetworks/${NIX_ENV_PREFIX}-my-azure-ad-attached-network
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}
)
(
    set -e
    fd-login-as-network-administrator
    az resource delete \
        --ids /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-my-subnet
    az resource delete \
        --ids /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet
    az resource delete \
        --ids /subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}
)
