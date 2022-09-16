nix::azure::cloud::is_registered() {
    local CLOUD=$1

    if [[ "${CLOUD}" == "${NIX_AZURE_CLOUD_DEFAULT}" ]]; then
        return
    fi

    if [[ "${CLOUD}" == "${AZURE_CLOUD_NAME}" ]]; then
        return
    fi

    nix::az::cloud::list \
        | grep "${CLOUD}" >/dev/null 2>&1
}

nix::azure::cloud::register() {
    local NAME="$1"
    shift

    local -n ENDPOINTS="$1"
    shift

    if nix::azure::cloud::is_registered "${NAME}"; then
        return
    fi

    local NIX_AZ_NAME="${NAME}"
    local NIX_AZ_TENANT_ENDPOINT_AD="${ENDPOINTS['endpoint-active-directory']}"
    local NIX_AZ_TENANT_ENDPOINT_AD_GRAPH_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-graph-resource-id']}"
    local NIX_AZ_TENANT_ENDPOINT_AD_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-resource-id']}"
    local NIX_AZ_TENANT_ENDPOINT_AD_DATA_LAKE_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-data-lake-resource-id']}"
    local NIX_AZ_TENANT_ENDPOINT_GALLERY="${ENDPOINTS['endpoint-gallery']}"
    local NIX_AZ_TENANT_ENDPOINT_RESOURCE_MANAGER="${ENDPOINTS['endpoint-resource-manager']}"
    local NIX_AZ_TENANT_ENDPOINT_MANAGEMENT="${ENDPOINTS['endpoint-management']}"
    local NIX_AZ_TENANT_ENDPOINT_SQL_MANAGEMENT="${ENDPOINTS['endpoint-sql-management']}"
    local NIX_AZ_TENANT_ENDPOINT_VM_IMAGE_ALIAS_DOC="${ENDPOINTS['endpoint-vm-image-alias-doc']}"

    nix::az::cloud::register
}