alias fd-ctx-grep="nix::context::emigrept | sort"
alias fd-ctx-list="nix::context::list | sort"
alias fd-ctx-print="nix::context::print | sort"
alias fd-ctx-clear="nix::context::clear"
alias fd-ctx-add="nix::context::add"
alias fd-ctx-ref="nix::context::ref"

nix::context::grep() {
    declare -p \
        | egrep -o --color=never -- "^declare -[n-] NIX_[A-Z_]+"
}

nix::context::list() {
    nix::context::grep \
        | egrep -o --color=never -- "NIX_[A-Z_]+"
}

nix::context::print() {
    nix::context::list \
        | pump nix::bash::variable::print
}

nix::context::clear() {
    mapfile -t < <(nix::context::list)
    unset -n "${MAPFILE[@]}"
}

nix::context::read() {
    while read -r NAME VALUE; do
        nix::context::add "${NAME}" "${VALUE}"
    done
}

nix::context::add() {
    local NAME="$1"
    shift

    local VALUE="$1"
    shift

    if [[ ! "${VALUE}" ]]; then
        return
    fi

    nix::intern::add "${VALUE}"
    local RO_VARIABLE="${REPLY}"

    nix::context::ref "${NAME}" "${RO_VARIABLE}"
}

nix::context::ref() {
    local NAME="$1"
    shift

    local RO_VARIABLE="$1"
    shift

    if [[ ! "${RO_VARIABLE}" ]]; then
        RO_VARIABLE=NIX_CONST_EMPTY
    fi

    if ! nix::bash::symbol::test "${RO_VARIABLE}"; then
        RO_VARIABLE=NIX_CONST_EMPTY
    fi

    ! nix::bash::symbol::test "${NAME}" \
        || [[ "${NAME}" =~ ^NIX_AZ ]] \
        || nix::assert "Context variable '${NAME}' already set to '${!NAME}' vs '${!RO_VARIABLE}'."

    # a readonly yet unsettable value
    nix::bash::symbol::readonly::test "${RO_VARIABLE}" \
        || nix::assert "Context variable '${RO_VARIABLE}' is not readonly."

    declare -gn "${NAME}=${RO_VARIABLE}"
}

