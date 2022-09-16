# https://dev.azure.com/devdiv/OnlineServices/_sprints/taskboard/Azure%20Lab%20Services%20-%20Fidalgo/OnlineServices/Copper/CY22%20Q3/2Wk/2Wk5?workitem=1593602
# https://dev.azure.com/devdiv/OnlineServices/_git/e742815b-4fb2-4fd7-acb3-b1d62a412ce1/commit/600dd82c6b5b0e656656f1257da3393567944e0a

PROJECT_NAME_63=\
nix-4567890123456789012345678901234567890123456789012345678901a
DEVCENTER_NAME_26=\
nix-4567890123456789012345

(
    set -ev
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
        --name ${DEVCENTER_NAME_26} \
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
        --dev-center-name ${DEVCENTER_NAME_26} \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --network-connection-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
    az devcenter admin devbox-definition create \
        --name ${NIX_ENV_PREFIX}-my-devbox-definition \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center-name ${DEVCENTER_NAME_26} \
        --image-reference \
            id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${DEVCENTER_NAME_26}/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
        --location ${NIX_FID_LOCATION} \
        --os-storage-type ssd_1024gb \
        --sku name=general_a_8c32gb_v1
    az devcenter admin project create \
        --name ${PROJECT_NAME_63} \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${DEVCENTER_NAME_26} \
        --location ${NIX_FID_LOCATION}
    az role assignment create \
        --assignee ${NIX_ENV_PERSONA_DEVELOPER} \
        --role "DevCenter Dev Box User" \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${PROJECT_NAME_63} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin pool create \
        --name ${NIX_ENV_PREFIX}-my-pool \
        --project-name ${PROJECT_NAME_63} \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --devbox-definition-name ${NIX_ENV_PREFIX}-my-devbox-definition \
        --location "${NIX_FID_LOCATION}" \
        --local-administrator Enabled \
        --license-type Windows_Client \
        --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network
)
(
    set -e
    fd-login-as-developer
    az devcenter dev dev-box create \
        --name ${NIX_ENV_PREFIX}-my-vm \
        --project-name ${PROJECT_NAME_63} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${DEVCENTER_NAME_26} \
        --pool-name ${NIX_ENV_PREFIX}-my-pool \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id)
        #--fidalgo-dns-suffix "${NIX_FID_DNS_SUFFIX}" \
    az devcenter dev dev-box show \
        --name ${NIX_ENV_PREFIX}-my-vm \
        --project-name ${PROJECT_NAME_63} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${DEVCENTER_NAME_26} \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id)
    az devcenter dev dev-box delete \
        --dev-box-name ${NIX_ENV_PREFIX}-my-vm \
        --project-name ${PROJECT_NAME_63} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center ${DEVCENTER_NAME_26} \
        --user-id $(fd-login-as-vm-user; az-signed-in-user-id) \
        --yes

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${PROJECT_NAME_63}/virtualmachine/${NIX_ENV_PREFIX}-my-vm \
        --verbose
)
(
    set -e
    fd-login-as-administrator
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${PROJECT_NAME_63}/pools/${NIX_ENV_PREFIX}-my-pool
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${PROJECT_NAME_63}
    
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devboxdefinitions/${NIX_ENV_PREFIX}-my-devbox-definition
    # Resource type devboxdefinitions not found.

    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${DEVCENTER_NAME_26}/attachednetworks/${NIX_ENV_PREFIX}-my-azure-ad-attached-network
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/networkconnections/${NIX_ENV_PREFIX}-my-azure-ad-network-connection
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${DEVCENTER_NAME_26}
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
