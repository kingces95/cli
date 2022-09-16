alias fd-switch-to-public="nix::env::tenant::switch ${NIX_PUBLIC_NAME}"
alias fd-switch-to-dogfood="nix::env::tenant::switch ${NIX_DOGFOOD_NAME}"
alias fd-switch-to-dogfood-int="nix::env::tenant::switch ${NIX_DOGFOOD_INT_NAME}"
alias fd-switch-to-selfhost="nix::env::tenant::switch ${NIX_SELFHOST_NAME}"
alias fd-switch-to-int="nix::env::tenant::switch ${NIX_INT_NAME}"
alias fd-switch-to-ppe="nix::env::tenant::switch ${NIX_PPE_NAME}"

alias fd-switch-to-selfhost-as-me="nix::env::tenant::switch ${NIX_SELFHOST_NAME} ${NIX_PERSONA_ME}"
alias fd-switch-to-int-as-me="nix::env::tenant::switch ${NIX_INT_NAME} ${NIX_PERSONA_ME}"
alias fd-switch-to-ppe-as-me="nix::env::tenant::switch ${NIX_PPE_NAME} ${NIX_PERSONA_ME}"

alias fd-logout="nix::env::tenant::logout"
alias fd-batch="nix::env::tenant::batch"

nix::env::tenant::logout() {
    nix::az::logout
}

nix::env::tenant::switch() {
    local NAME="${1:-${NIX_PUBLIC_NAME}}"
    shift

    local PERSONA="${1:-${NIX_PERSONA_ADMINISTRATOR}}"
    shift

    if [[ "${NIX_FID_NAME}" == "${NAME}" ]] \
        && [[ "${NIX_ENV_PERSONA}" == "${PERSONA}" ]] \
        && nix::az::account::get_access_token::check; then

        # refresh for development purposes 
        nix::env::set "${NAME}" "${PERSONA}"
        return
    fi

    if ! nix::env::set "${NAME}" "${PERSONA}"; then
        return
    fi

    if ! nix::env::tenant::login; then
        return 1
    fi

    # dogfood dataplane requires a proxy
    if [[ "${NIX_ENV_CLOUD}" == 'Dogfood' ]]; then
        nix::proxy::install
        nix::proxy::enable
    else
        nix::proxy::disable
    fi

    nix::env::cli::install >&2
}

nix::env::tenant::login() {
    local ARGS=(
        "${NIX_ENV_UPN}"
        "${NIX_ENV_TENANT}"
        "${NIX_ENV_CLOUD}"
        NIX_ENV_CLOUD_ENDPOINTS
        "${NIX_ENV_SUBSCRIPTION}"
        "${NIX_ENV_SUBSCRIPTION_NAME}"
        "${NIX_ENV_RESOURCE_GROUP}"
        "${NIX_ENV_LOCATION}"
    )

    # login with token
    if [[ "${NIX_ENV_UPN}" == "${NIX_ENV_PERSONA_ME}" ]]; then
        nix::azure::tenant::login "${ARGS[@]}"
        return
    fi

    ARGS+=( "$(nix::secret::azure::password::get)" )

    # try login with secret
    if ! nix::azure::tenant::login "${ARGS[@]}"; then

        # initialize persona; assume login failed because user does not exist
        if ! nix::env::persona::create; then
            return 1
        fi

        # try login again
        local DELAY=15
        local TRYS=$(( NIX_ACCOUNT_MFA_ACTIVATION_TIMEOUT_MINUTES * 60 / DELAY ))
        nix::bash::args 'nix::azure::tenant::login' "${ARGS[@]}" \
            | nix::sync::retry "${TRYS}" "${DELAY}" \
                "nix: persona: installing ${NIX_ENV_PERSONA}"

        # display error message, if any
        nix::azure::tenant::login "${ARGS[@]}" 1>/dev/null
    fi 
}

nix::env::tenant::eval() (
    local ENVIRONMENT="$1"
    shift

    nix::env::tenant::switch "${ENVIRONMENT}"
    "$@"
)

nix::env::tenant::batch() (
    local ENVIRONMENT
    for ENVIRONMENT in "${NIX_MY_ENVIRONMENTS[@]}"; do
        nix::env::tenant::eval "${ENVIRONMENT}" "$@" 2>&1 \
            | sed "s/^/${ENVIRONMENT} /g"
    done
)

