alias fd-who="nix::env::who"
alias fd-nix="nix::bash::dump::variables NIX_ | a2f"
alias fd-nix-raw="nix::bash::dump::variables NIX_"
alias fd-nix-env="nix::env::records | a2f"
alias fd-nix-env-www="nix::env::records::www | a2"
alias fd-nix-cpc="nix::env::records::cpc | a2f"
alias fd-nix-fid="nix::env::records::fid | a2f"
alias fd-subscriptions="nix::env::query::subscriptions"

nix::env::records() {
    nix::bash::dump::variables NIX_ENV_
}

nix::env::records::fid() {
    nix::bash::dump::variables NIX_FID_
}

nix::env::records::cpc() {
    nix::bash::dump::variables NIX_CPC_
}

nix::env::records::www() {
    nix::bash::dump::variables NIX_FID_WWW
    nix::bash::dump::variables NIX_CPC_WWW
}

nix::env::who() {
    local LIST=(
        'header env'
        NIX_ENV_PERSONA
        NIX_ENV_UPN
        NIX_ENV_RESOURCE_GROUP
        NIX_ENV_SUBSCRIPTION
        NIX_ENV_SUBSCRIPTION_NAME
        NIX_ENV_TENANT
        NIX_ENV_CLOUD
        NIX_ENV_LOCATION
        NIX_ENV_CLI_VERSION
        NIX_ENV_PREFIX

        'header fid'
        NIX_FID_NAME
        NIX_FID_AFS_SUBSCRIPTION_DIR

        'header cpc'
        NIX_CPC_NAME
        NIX_CPC_AFS_SUBSCRIPTION_DIR

        'header azure'
        AZURE_CONFIG_DIR
        AZURE_CLOUD_NAME
        AZURE_DEFAULTS_GROUP
        AZURE_DEFAULTS_LOCATION
        HTTPS_PROXY

        'header kusto'
        NIX_KUSTO_TOKEN_URL
        NIX_KUSTO_ENV_DATA_SOURCE
        NIX_KUSTO_ENV_INITIAL_CATALOG
        NIX_KUSTO_QUERY_DIR

        'header my'
        NIX_USER
        NIX_PROFILE
        NIX_MY_ENV_ID
    )

    local HEADER NAME

    while read _ HEADER; do
        echo "${HEADER}"
        while read NAME; do
            printf '%-30s %s\n' "${NAME}" "${!NAME}"
        done < <(nix::line::take::chunk) \
            | nix::bash::emit::indent
        echo
    done < <(
        nix::bash::args "${LIST[@]}" \
            | nix::line::chunk '^header'
    )
}

nix::env::query::subscriptions() {
    az account list --query '[].[id, state, isDefault, name]' --output tsv
}
