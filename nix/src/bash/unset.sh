nix::bash::unset::variables() {
    nix::bash::dump::variables "$@" \
        | pump2 nix::bash::unset
}

nix::bash::unset::functions() {
    mapfile -t < <(
        nix::bash::dump::functions "$@" \
            | grep "^$1"
    )

    local FUNCTION
    for FUNCTION in "${MAPFILE[@]}"; do
        unset -f "${FUNCTION}"
    done
}

nix::bash::unset() {
    unset "$1"
    unset -n "$1"
}

nix::bash::unset::function() {
    unset -f "$1"
}
