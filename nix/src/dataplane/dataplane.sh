alias dp="alias -p | grep dp-"
alias dp-vm-put="nix::dataplane::vm::put"
alias dp-vm-get="nix::dataplane::vm::get"
alias dp-pool-get="nix::dataplane::pool::get"

nix::js::replace() {
    :
}

nix::dataplane::vm::put() {
    local PROJECT=${1-${NIX_FIDALGO_PROJECT}}
    local POOL=${2-${NIX_FIDALGO_POOL}}
    local VM=${3-${NIX_FIDALGO_VM}}

    local PTH=projects/${PROJECT}/users/me/virtualmachines/${VM}

    nix::dataplane::json::cat ${FUNCNAME} \
        | jq "(.. | .poolName?) |= \"${POOL}\"" \
        | nix::http::curl::put ${PTH}
}

nix::dataplane::vm::get() {
    local PROJECT=${1-${NIX_FIDALGO_PROJECT}}
    local VM=${2-${NIX_FIDALGO_VM}}

    nix::http::curl "projects/${PROJECT}/users/me/virtualmachines/${VM}"
}

nix::dataplane::pool::get() {
    local PROJECT=${1-${NIX_FIDALGO_PROJECT}}
    local VM=${2-${NIX_FIDALGO_VM}}

    # nix::http::curl "projects/${PROJECT}/users/me/virtualmachines/${VM}"
    nix::dataplane
}

nix::dataplane::function_to_json_file_name() {
    local FUNCTION="$1"
    nix::bash::args ${FUNCTION//::/ } \
        | nix::line::skip 1 \
        | nix::line::join '-'
}

nix::dataplane::json::cat() {
    local NAME=$(nix::dataplane::function_to_json_file_name "$@")
    cat "$(find "${NIX_DIR_NIX_SRC}" -type f -name "${NAME}.json")"
}