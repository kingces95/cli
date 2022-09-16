nix::tool::stub() {
    local TOOL="${FUNCNAME[1]}"

    local TOOL_PATH="$(which ${TOOL})"
    if [[ ! "${TOOL_PATH}" ]]; then
        nix::tool::install "${TOOL}"
        TOOL_PATH="$(which ${TOOL})"
    fi

    "${TOOL_PATH}" "$@"
}
