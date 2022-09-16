nix::spy() {
    local -n NIX_SPY_REF="$1"
    shift

    local NAME="$1"
    shift

    if [[ "${NIX_SPY_REF}" == "${NAME}" ]]; then
        "${NAME}" "$@" >&3
        cat > /dev/null
        return 1
    fi
    
    if ! read -r; then
        return 1
    fi

    "${NAME}" "$@" < <(
        echo "${REPLY}"
        cat
    )
}
