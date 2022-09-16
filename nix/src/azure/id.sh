nix::azure::resource::www() {
    local PORTAL_HOST="$1"
    shift

    local TENANT_HOST="$1"
    shift

    local ID="$1"
    shift
    
    local SEGMENTS=()
    if [[ "${PORTAL_HOST}" ]]; then
        SEGMENTS+=( "${PORTAL_HOST}" )
    fi

    if [[ "${TENANT_HOST}" ]]; then
        SEGMENTS+=( "#@${TENANT_HOST}" )
    fi

    if [[ "${ID}" ]]; then
        SEGMENTS+=( "resource" )
        SEGMENTS+=( "${ID}" )
    fi

    local IFS=/
    echo "${NIX_HTTP_SECURE}${SEGMENTS[*]}"
}

nix::azure::resource::id() {
    local SUBSCRIPTION="$1"
    shift

    local RESOURCE_GROUP="$1"
    shift

    local PROVIDER="$1"
    shift

    local RESOURCE="$1"
    shift

    local NAME="$1"
    shift

    local ID=()
    if [[ "${SUBSCRIPTION}" ]]; then
        ID+=( "subscriptions" )
        ID+=( "${SUBSCRIPTION}" )
    fi

    if [[ "${RESOURCE_GROUP}" ]]; then
        ID+=( "resourceGroups" )
        ID+=( "${RESOURCE_GROUP}" )
    fi

    if [[ "${PROVIDER}" ]]; then
        ID+=( "providers" )
        ID+=( "${PROVIDER}" )
    fi

    if [[ "${RESOURCE}" ]]; then
        ID+=( "${RESOURCE}" )
    fi

    if [[ "${NAME}" ]]; then
        ID+=( "${NAME}" )
    fi

    local IFS=/
    echo "${ID[*]}"
}

nix::azure::resource::id::vm() {
    local SUBSCRIPTION="$1"
    shift

    local RESOURCE_GROUP="$1"
    shift

    local NAME="$1"
    shift

    nix::azure::resource::id \
        "${SUBSCRIPTION}" \
        "${RESOURCE_GROUP}" \
        'Microsoft.Compute' \
        'virtualMachines' \
        "${NAME}"
}

nix::azure::resource::id::vnet() {
    local SUBSCRIPTION="$1"
    shift

    local RESOURCE_GROUP="$1"
    shift

    local NAME="$1"
    shift

    nix::azure::resource::id \
        "${SUBSCRIPTION}" \
        "${RESOURCE_GROUP}" \
        'Microsoft.Network' \
        'virtualNetworks' \
        "${NAME}"
}
