alias fd-profile="code ${NIX_PROFILE}"
alias fd-profile-rm="nix::profile::remove"
alias fd-cpc-resources="nix::profile::resource::report"

nix::profile::remove() {
    rm -r "${NIX_HOME}"
}

nix::profile::group::list() {
    az group list \
        --query '[?starts_with(name,`nix-chrkin`)].name' \
        --output tsv \
        --subscription=${NIX_CPC_SUBSCRIPTION}
}

nix::az::resource::list() {
    local -a AZGROUPS=( "$@" )

    local AZGROUP
    for AZGROUP in "${AZGROUPS[@]}"; do
        az resource list \
            --resource-group=${AZGROUP} \
            --query '[].[name,type]' \
            --output tsv \
            --subscription=${NIX_CPC_SUBSCRIPTION}
    done
}

nix::profile::resource::list() {
    local -a AZGROUPS
    mapfile AZGROUPS < <(nix::profile::group::list)

    local AZGROUP
    for AZGROUP in "${AZGROUPS[@]}"; do
        az resource list \
            --resource-group=${NIX_MY_RESOURCE_GROUP} \
            --query='[].[resourceGroup,name,type]' \
            --output=tsv \
            --subscription=${NIX_CPC_SUBSCRIPTION}
    done
}

nix::resource::vnet::report() {
    local NIX_AZ_RESOURCE_GROUP=$1
    shift

    local NIX_AZ_SUBSCRIPTION=$1
    shift

    nix::az::network::vnet::list | {
        while read NIX_AZ_NAME; do
            echo "name ${NIX_AZ_NAME}"

            local LOCATION="$(nix::az::network::vnet::location)"
            local DNS="$(nix::az::network::vnet::dns)"

            echo "option" "location" "${LOCATION}"
            echo "option" "dns" "${DNS}"

            echo "push subnet"
            local NIX_AZ_VENT_NAME="${NIX_AZ_NAME}"
            nix::az::network::vnet::subnet::list | {
                while read NAME; do
                    nix::resource::subnet::report "${NAME}"
                done
            }
            echo "pop"
        done
    }
}

nix::resource::subnet::report() {
    local NIX_AZ_NAME="$1"
    shift

    local ADDRESS_PREFIX=$(nix::az::network::vnet::subnet::address_prefix)
    local DELEGATION=$(nix::az::network::vnet::subnet::delegation)

    echo 'name' "${NIX_AZ_NAME}" 
    echo 'option' 'addressPrefix' "${ADDRESS_PREFIX}" 
    echo 'option' 'delegation' "${DELEGATION}"
}

nix::profile::resource::report() (
    nix::env::persona::switch "${NIX_PERSONA_NETWORK_ADMINISTRATOR}"

    local SUBSCRIPTION=${NIX_CPC_SUBSCRIPTION}
    local RG=${NIX_MY_RESOURCE_GROUP}
    local PORTAL_HOST=${NIX_CPC_PORTAL_HOST}
    local TENANT_HOST=${NIX_CPC_TENANT_HOST}

    local NAME TYPE
    while read NAME TYPE; do
        local URL="https://${PORTAL_HOST}"
        URL+="/#@${HOST}/resource"
        URL+="/subscriptions/${SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/${TYPE}/${NAME}"
        URL+='/overview'

        echo "${NAME} ${URL}"
    done < <(nix::profile::resource::list)
)

# # to-ad
# az network vnet peering list \
#     --resource-group=permtest \
#     --vnet-name=vNetPermTest \
#     --subscription=5107c0cd-1b38-45e5-ad53-5308aeafd97a

# # from-ad
# az network vnet peering list \
#     --resource-group=fidalgoppe010 \
#     --vnet-name=vnet \
#     --subscription=974ae608-fbe5-429f-83ae-924a64019bf3 \
#     --query '[?name == `vNetPermTestPeering`]'
