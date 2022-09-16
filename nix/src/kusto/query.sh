nix::kusto::query::infer_type() {
    local VALUE="$1"

    local REGEX
    for REGEX in "${!NIX_KUSTO_TYPE_REGEX[@]}"; do
        if [[ "${VALUE}" =~ ${REGEX} ]]; then
            echo "${NIX_KUSTO_TYPE_REGEX["${REGEX}"]}"
            return
        fi
    done

    echo "[Unknown Type '${VALUE}']"
}
