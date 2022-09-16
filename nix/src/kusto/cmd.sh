alias kusto-token="nix::kusto::token"
alias kusto-dump="nix::kusto::cmd::dump | a2f"

nix::kusto::token() {
    nix::az::account::get_access_token "${NIX_KUSTO_TOKEN_URL}"
}

nix::kusto::connection_string() {
    read < <(nix::kusto::token)
    declare -A CONNECTION=(
        ["DataSource"]="${NIX_KUSTO_ENV_DATA_SOURCE}"
        ["InitialCatalog"]="${NIX_KUSTO_ENV_INITIAL_CATALOG}"
        ["Fed"]=true
        ["UserToken"]="${REPLY}"
    )

    nix::bash::map::write CONNECTION \
        | awk '{printf "%s=%s\n", $1, $2}' \
        | nix::line::join ';' \
        | sed 's/DataSource/Data Source/' \
        | sed 's/InitialCatalog/Initial Catalog/'
}

nix::kusto::cmd::dump() {
    echo "dll ${NIX_KUSTO_DLL}"
    echo "token-url ${NIX_KUSTO_TOKEN_URL}"
    echo "data-source ${NIX_KUSTO_ENV_DATA_SOURCE}"
    echo "initial-catalog ${NIX_KUSTO_ENV_INITIAL_CATALOG}"
}
