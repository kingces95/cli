alias fd-az-tenant-profile-path="nix::azure::tenant::profile::path"

nix::azure::tenant::profile::clear() {
    if [[ ! -d "${NIX_AZURE_PID_DIR}" ]]; then
        return
    fi

    rm -r "${NIX_AZURE_PID_DIR}"
}

nix::azure::tenant::profile::set() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    nix::azure::env::config_dir::export "$(nix::azure::tenant::profile::dir "${UPN}" "${TENANT}")"
}

nix::azure::tenant::profile::dir() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    echo "${NIX_AZURE_PID_DIR}/${TENANT}/${UPN}"
}

nix::azure::tenant::profile::path() {
    echo "${AZURE_CONFIG_DIR}/${NIX_AZURE_PROFILE_FILE}"
}

nix::azure::tenant::profile::skeleton() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="${1-"[Anonymous]"}"
    shift

    cat <<-EOF
	{
	    "installationId": "$(nix::guid::generate)",
	    "subscriptions": [
	        {
	            "id": "${SUBSCRIPTION}",
	            "name": "${SUBSCRIPTION_NAME}",
	            "state": "Enabled",
	            "user": {
	                "name": "${UPN}",
	                "type": "user"
	            },
	            "isDefault": true,
	            "tenantId": "${TENANT}",
	            "environmentName": "${CLOUD}",
	            "homeTenantId": "${TENANT}",
	            "managedByTenants": []
	        }
	    ]
	}
	EOF
}

nix::azure::tenant::profile::initialize() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="$1"
    shift

    local PTH="$(nix::azure::tenant::profile::path)"
    if [[ -s "${PTH}" ]]; then
        return
    fi

    # create profile
    nix::fs::touch "${PTH}"

    nix::azure::tenant::profile::skeleton \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}" \
        > "${PTH}"
}

nix::azure::tenant::profile::share_tokens() {

    mkdir -p "${AZURE_CONFIG_DIR}"

    # create shared msal_token_cache.json
    if [[ ! -f "${NIX_AZURE_TOKEN_CACHE}" ]]; then
        touch "${NIX_AZURE_TOKEN_CACHE}"
    fi

    # only share if no tokens already cached
    if [[ -f "${AZURE_CONFIG_DIR}/${NIX_AZURE_TOKEN_CACHE_FILE}" ]]; then
        return
    fi

    # link to shared msal_token_cache.json
    ln -s "${NIX_AZURE_TOKEN_CACHE}" "${AZURE_CONFIG_DIR}"
}
