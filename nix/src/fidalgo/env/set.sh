nix::env::set() {
    local NAME="$1"
    shift

    local PERSONA="$1"
    shift
    
    nix::context::clear

    nix::context::add NIX_FID_NAME                      "${NAME}" # PUBLIC
    nix::context::ref NIX_CPC_NAME                      "NIX_${NAME}_CPC" # SELFHOST

    nix::env::afs::fid::set "${NIX_FID_NAME,,}/default"
    nix::env::afs::cpc::set "${NIX_CPC_NAME,,}/default"
    nix::env::afs::hobo::set "public/hobodf"

    nix::env::set::common "FID"
    nix::env::set::common "CPC"

    nix::context::add NIX_ENV_PREFIX                    "nix-${NIX_USER}-${NIX_FID_TAG}-${NIX_MY_ENV_ID}" # nix-chrkin-df-0
    nix::context::add NIX_FID_RESOURCE_GROUP            "${NIX_ENV_PREFIX}-fid-rg" # nix-chrkin-df-0-rg
    nix::context::add NIX_CPC_RESOURCE_GROUP            "${NIX_ENV_PREFIX}-cpc-rg" # nix-chrkin-df-0-rg

    nix::env::fid::set "${NIX_FID_NAME}"
    nix::env::cpc::set "${NIX_CPC_NAME}"
    nix::env::env::set "${PERSONA}"

    nix::env::kusto::set "${NIX_FID_NAME}"

    # for debugging
    # return 1
}

nix::env::env::set() {
    local PERSONA="$1"                                                  # administrator

    nix::context::add NIX_ENV_PERSONA_ME                "${!NIX_PERSONA_UPN[${NIX_PERSONA_ME}]}"
    nix::context::add NIX_ENV_PERSONA_ADMINISTRATOR     "${!NIX_PERSONA_UPN[${NIX_PERSONA_ADMINISTRATOR}]}"
    nix::context::add NIX_ENV_PERSONA_DEVELOPER         "${!NIX_PERSONA_UPN[${NIX_PERSONA_DEVELOPER}]}"
    nix::context::add NIX_ENV_PERSONA_NETWORK_ADMIN     "${!NIX_PERSONA_UPN[${NIX_PERSONA_NETWORK_ADMINISTRATOR}]}"
    nix::context::add NIX_ENV_PERSONA_VM_USER           "${!NIX_PERSONA_UPN[${NIX_PERSONA_VM_USER}]}"
    nix::context::add NIX_ENV_PERSONA_VM_USER_SYNC      "${!NIX_PERSONA_UPN[${NIX_PERSONA_VM_USER_SYNC}]}"

    nix::context::add NIX_ENV_PERSONA                   "${PERSONA}"    # administrator

    local UPN="${NIX_PERSONA_UPN[${PERSONA}]}"                          # NIX_FID_UPN_DOMAIN_ADMIN
    nix::context::add NIX_ENV_UPN                       "${!UPN}"       # chrkin-admin@fidalgoppe010.onmicrosoft.com

    local ENV='FID'
    if [[ "${UPN}" =~ _CPC_ ]]; then
        ENV='CPC'
    fi

    nix::context::ref NIX_ENV_TENANT                    "NIX_${ENV}_TENANT"
    nix::context::ref NIX_ENV_CLOUD                     "NIX_${ENV}_CLOUD"
    nix::context::ref NIX_ENV_CLOUD_ENDPOINTS           "NIX_${ENV}_CLOUD_ENDPOINTS"
    nix::context::ref NIX_ENV_SUBSCRIPTION              "NIX_${ENV}_SUBSCRIPTION"
    nix::context::ref NIX_ENV_SUBSCRIPTION_NAME         "NIX_${ENV}_SUBSCRIPTION_NAME"
    nix::context::ref NIX_ENV_CLI_VERSION               "NIX_${ENV}_CLI_VERSION"
    nix::context::ref NIX_ENV_TENANT_HOST               "NIX_${ENV}_TENANT_HOST"
    nix::context::ref NIX_ENV_TENANT_SUBDOMAIN          "NIX_${ENV}_TENANT_SUBDOMAIN"
    nix::context::ref NIX_ENV_RESOURCE_GROUP            "NIX_${ENV}_RESOURCE_GROUP"
    nix::context::ref NIX_ENV_LOCATION                  "NIX_${ENV}_LOCATION"
}

nix::env::hobo::set() {
    :
}

nix::env::fid::set() {
    local NAME=$1
    shift

    # nix::context::add NIX_FID_LOCATION                "$(nix::env::fid::query NIX_AZ_TENANT_DEFAULT_LOCATION)" # centraluseuap
}

nix::env::cpc::set() {
    local NAME=$1
    shift

    # vnet
    nix::context::ref NIX_CPC_DC_VNET                   "NIX_${NIX_CPC_NAME}_DC_VNET"
    nix::context::ref NIX_CPC_DC_VNET_RESOURCE_GROUP    "NIX_${NIX_CPC_NAME}_DC_VNET_RESOURCE_GROUP"
    nix::context::add NIX_CPC_ID_DC_VNET "$(
        nix::azure::resource::id::vnet \
            ${NIX_CPC_SUBSCRIPTION} \
            ${NIX_CPC_DC_VNET_RESOURCE_GROUP} \
            ${NIX_CPC_DC_VNET}
        )"
    nix::context::add NIX_CPC_WWW_DC_VNET "$(
        nix::azure::resource::www \
            ${NIX_CPC_PORTAL_HOST} \
            ${NIX_CPC_TENANT_HOST} \
            ${NIX_CPC_ID_DC_VNET}
        )"

    # domain controller
    nix::context::ref NIX_CPC_DC                        "NIX_${NIX_CPC_NAME}_DC"
    nix::context::ref NIX_CPC_DC_RESOURCE_GROUP         "NIX_${NIX_CPC_NAME}_DC_RESOURCE_GROUP"
    nix::context::add NIX_CPC_ID_DC "$(
        nix::azure::resource::id::vm \
            ${NIX_CPC_SUBSCRIPTION} \
            ${NIX_CPC_DC_RESOURCE_GROUP} \
            ${NIX_CPC_DC}
        )"
    nix::context::add NIX_CPC_WWW_DC "$(
        nix::azure::resource::www \
            ${NIX_CPC_PORTAL_HOST} \
            ${NIX_CPC_TENANT_HOST} \
            ${NIX_CPC_ID_DC}
        )"

    # domain credentials
    nix::context::add NIX_CPC_DOMAIN_NAME               "${NIX_CPC_TENANT_SUBDOMAIN}.local"
    nix::context::add NIX_CPC_DOMAIN_JOIN_ACCOUNT       "domainjoin@${NIX_CPC_TENANT_SUBDOMAIN}.local"
    nix::context::ref NIX_CPC_DNS                       "NIX_${NIX_CPC_NAME}_DNS"

    # misc
    nix::context::add NIX_CPC_WWW_MEM                   "NIX_${NIX_CPC_NAME}_WWW_MEM"
    nix::context::add NIX_CPC_WWW_END_USER              "NIX_${NIX_CPC_NAME}_WWW_END_USER"
}

nix::env::set::common() {
    local ENV="$1"
    shift

    # computed variable declarations
    nix::context::add "NIX_${ENV}_TENANT_HOST"          "$(nix::env::host ${ENV})"                                      # NIX_FID_TENANT_HOST           NIX_CPC_TENANT_HOST             fidalgoppe010.onmicrosoft.com
    nix::context::add "NIX_${ENV}_UPN_DOMAIN"           "$(nix::env::user ${ENV} ${NIX_USER})"                          # NIX_FID_UPN_DOMAIN            NIX_CPC_UPN_DOMAIN              chrkin@fidalgoppe010.onmicrosoft.com       
    nix::context::add "NIX_${ENV}_UPN_DOMAIN_ADMIN"     "$(nix::env::user ${ENV} ${NIX_USER}-${NIX_ACCOUNT_ADMIN})"     # NIX_FID_UPN_DOMAIN_ADMIN      NIX_CPC_UPN_DOMAIN_ADMIN        chrkin-admin@fidalgoppe010.onmicrosoft.com
    nix::context::add "NIX_${ENV}_UPN_DOMAIN_USER"      "$(nix::env::user ${ENV} ${NIX_USER}-${NIX_ACCOUNT_USER})"      # NIX_FID_UPN_DOMAIN_USER       NIX_CPC_UPN_DOMAIN_USER         chrkin-user@fidalgoppe010.onmicrosoft.com
    nix::context::add "NIX_${ENV}_UPN_DOMAIN_USER_SYNC" "$(nix::env::user ${ENV} ${NIX_USER}-${NIX_ACCOUNT_USER_SYNC})" # NIX_FID_UPN_DOMAIN_USER_SYNC  NIX_CPC_UPN_DOMAIN_USER_SYNC    chrkin-sync@fidalgoppe010.onmicrosoft.com

    # computed indirect variable declarations
    declare -gn "NIX_${ENV}_CLOUD_ENDPOINTS=$(nix::env::cloud_endpoints ${ENV})"                        # NIX_FID_CLOUD_ENDPOINTS   NIX_CPC_CLOUD_ENDPOINTS     NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC

    # load bookmarks
    nix::env::set::common::www "${ENV}"
}

nix::env::set::common::www() {
    local ENV="$1"
    shift

    local -n PORTAL_HOST="NIX_${ENV}_PORTAL_HOST"
    local -n TENANT_HOST="NIX_${ENV}_TENANT_HOST"
    local -n SUBSCRIPTION="NIX_${ENV}_SUBSCRIPTION"

    nix::context::add "NIX_${ENV}_WWW" "$(               # NIX_FID_WWW               NIX_CPC_WWW                 https://portal.azure.com
        nix::azure::resource::www \
            "${PORTAL_HOST}"
        )"                

    nix::context::add "NIX_${ENV}_WWW_SUBSCRIPTION" "$(  # NIX_FID_WWW_SUBSCRIPTION  NIX_CPC_WWW_SUBSCRIPTION
        nix::azure::resource::www \
            "${PORTAL_HOST}" \
            "${TENANT_HOST}" \
            $(nix::azure::resource::id "${SUBSCRIPTION}")
        )" 
}

nix::env::kusto::set() {
    local TENANT="$1"
    shift

    local -n KUSTO_TENANT="NIX_${TENANT}_KUSTO"

    # indirect variables
    nix::context::ref "NIX_KUSTO_ENV_CLUSTER"           "NIX_KUSTO_${KUSTO_TENANT}_CLUSTER"
    nix::context::ref "NIX_KUSTO_ENV_DATA_SOURCE"       "NIX_KUSTO_${KUSTO_TENANT}_DATA_SOURCE"
    nix::context::ref "NIX_KUSTO_ENV_INITIAL_CATALOG"   "NIX_KUSTO_${KUSTO_TENANT}_INITIAL_CATALOG"
}

nix::env::cloud_endpoints() {
    local NAME="$1"
    shift

    local -n CLOUD="NIX_${NAME}_CLOUD"
    echo "${NIX_AZURE_CLOUD_ENDPOINTS[${CLOUD}]}"
}

nix::env::user() {
    local NAME="$1"
    shift

    local ALIAS="$1"
    shift

    local TENANT_HOST="$(nix::env::host ${NAME})"
    
    # e.g. we cannot create accounts in public/dogfood; use microsoft alias
    if nix::bash::map::test NIX_UPN_OVERRIDE "${TENANT_HOST}"; then
        
        # chrkin@microsoft.com
        echo "${NIX_UPN_MICROSOFT}"
        return
    fi

    # chrkin@fidalgoppe010.onmicrosoft.com
    echo "${ALIAS}@${TENANT_HOST}"
}

nix::env::host() {
    local NAME="$1"
    shift

    local -n TENANT_DOMAIN="NIX_${NAME}_TENANT_DOMAIN"
    local -n TENANT_SUBDOMAIN="NIX_${NAME}_TENANT_SUBDOMAIN"

    nix::bash::join '.' \
        "${TENANT_SUBDOMAIN}" \
        "${TENANT_DOMAIN}"
}
