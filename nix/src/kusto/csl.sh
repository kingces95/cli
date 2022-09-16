alias kusto-csl-find="nix::fidalgo::kusto::csl::find"
alias kusto-csl-harvest="nix::kusto::csl::harvest NIX_REPO_DIR_KUSTO"

nix::kusto::csl::find() (
    local PTH="$1"
    cd "${PTH}" 

    find -type f -name '*.csl' \
        | sort
)

nix::kusto::csl::harvest() (
    local ROOT_VARIABLE="$1"

    nix::kusto::csl::find "${!ROOT_VARIABLE}" \
        | sort \
        | pump nix::kusto::csl::path_to_alias "${ROOT_VARIABLE}"
)

nix::kusto::csl::path_to_alias() {
    local PTH="$1"
    shift

    local ROOT_VARIABLE="$1"
    shift

    local ALIAS=$(nix::path::to_alias "${PTH}")
    local BASE_PATH=$(nix::path::absolute "${PTH}" "\${${ROOT_VARIABLE}}")
    echo "${ALIAS}" "cat '${BASE_PATH}' | nix::kusto::query" \
        | pump2 nix::bash::emit::alias
}
