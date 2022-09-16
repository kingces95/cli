(
    set -e
    fd-login-as-administrator
    az group create \
        --name ${NIX_MY_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --location ${NIX_MY_LOCATION}
    az network vnet create \
        --name ${NIX_MY_VNET} \
        --resource-group ${NIX_MY_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes ${NIX_MY_IP_ALLOCATION} \
        --location ${NIX_MY_LOCATION} \
        --dns-servers ${NIX_PPE_DNS}
    az network vnet subnet create \
        --name default \
        --vnet-name ${NIX_MY_VNET} \
        --resource-group ${NIX_MY_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --address-prefixes ${NIX_MY_IP_ALLOCATION}

    MY_VNET_ID=$(
        az network vnet show \
            --name ${NIX_MY_VNET} \
            --resource-group ${NIX_MY_RESOURCE_GROUP} \
            --subscription ${NIX_CPC_SUBSCRIPTION} \
            --query id --out tsv
    )

    # resolve domain controller vnet id
    az account list --refresh
    DOMAIN_CONTROLLER_VNET='DomainController-vnet'
    DOMAIN_CONTROLLER_GROUP='Networks'
    DOMAIN_CONTROLLER_SUBSCRIPTION='f141e9f2-4778-45a4-9aa0-8b31e6469454'
    DOMAIN_CONTROLLER_VNET_ID=$(
        az network vnet show \
            --name ${DOMAIN_CONTROLLER_VNET} \
            --resource-group ${DOMAIN_CONTROLLER_GROUP} \
            --subscription ${DOMAIN_CONTROLLER_SUBSCRIPTION} \
            --query id --out tsv
    )

    # pair my vnet with domain controller vnet
    az network vnet peering create \
        --name "${NIX_MY_VNET}-${DOMAIN_CONTROLLER_VNET}" \
        --vnet-name ${NIX_MY_VNET} \
        --resource-group ${NIX_MY_RESOURCE_GROUP} \
        --subscription ${NIX_CPC_SUBSCRIPTION} \
        --remote-vnet ${DOMAIN_CONTROLLER_VNET_ID?} \
        --allow-forwarded-traffic \
        --allow-vnet-access
    az network vnet peering create \
        --name "${DOMAIN_CONTROLLER_VNET}-${NIX_MY_VNET}" \
        --vnet-name ${DOMAIN_CONTROLLER_VNET} \
        --resource-group ${DOMAIN_CONTROLLER_GROUP} \
        --subscription ${DOMAIN_CONTROLLER_SUBSCRIPTION} \
        --remote-vnet ${MY_VNET_ID?} \
        --allow-forwarded-traffic \
        --allow-vnet-access

    colordiff -y <(
        az network vnet show \
            --name chrkin-vnet \
            --resource-group chrkin-rg \
            --subscription ${NIX_FID_SUBSCRIPTION}
    ) <(
        az network vnet show \
            --name ${NIX_MY_VNET} \
            --resource-group ${NIX_MY_RESOURCE_GROUP} \
            --subscription ${NIX_FID_SUBSCRIPTION}
    )
)
