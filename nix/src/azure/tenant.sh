nix::azure::tenant::public::eval() (
    local UPN="${NIX_UPN_MICROSOFT}"
    local TENANT="${NIX_PUBLIC_TENANT}"
    local CLOUD="${NIX_AZURE_CLOUD_DEFAULT}"
    local CLOUD_ENDPOINTS="NIX_PUBLIC_CLOUD_ENDPOINTS"
    local SUBSCRIPTION="${NIX_PUBLIC_SUBSCRIPTION}"
    local SUBSCRIPTION="${NIX_PUBLIC_SUBSCRIPTION_NAME}"

    if ! nix::azure::tenant::login \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${CLOUD_ENDPOINTS}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}" \
         >/dev/null
    then
        nix::assert "Login failed."
        return
    fi

    # execute as me in public (e.g. kusto)
    "$@"
)

nix::azure::tenant::login() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local CLOUD_ENDPOINTS="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="$1"
    shift

    local GROUP="$1"
    shift

    local LOCATION="$1"
    shift
    
    local SECRET="$1"
    shift

    nix::azure::tenant::profile::set "${UPN}" "${TENANT}"

    nix::azure::tenant::profile::initialize \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}"

    nix::azure::tenant::profile::share_tokens

    nix::azure::cloud::register "${CLOUD}" "${CLOUD_ENDPOINTS}"
    nix::azure::env::cloud::export "${CLOUD}"
    nix::azure::env::defaults::group::export "${GROUP}"
    nix::azure::env::defaults::location::export "${LOCATION}"

    if nix::az::account::get_access_token::check; then
        return
    fi

    if [[ ! "${SECRET}" ]]; then
        if ! nix::bash::tty::test; then
            echo "nix: terminal unavailable: cannot login with device code." >&2
            return 1
        fi

        nix::az::login::with_device_code "${TENANT}" >/dev/null
    else
        (
            nix::log::subproc::begin "nix: az: authenticating ${UPN}"
            nix::az::login::with_secret \
                "${UPN}" \
                "${SECRET}" \
                "${TENANT}"
        ) 
    fi
}
