alias fd-intern-initialize="nix::intern::initialize"
alias fd-intern-list="nix::intern::list"
alias fd-intern-dump="nix::intern::dump | a2f"
alias fd-intern-test="nix::intern::test"
alias fd-intern-add="nix::intern::add"

nix::intern::initialize() {
    declare -gA RO_STRING+=()
}

nix::intern::list() {
    nix::intern::initialize
    printf '%s\n' "${!RO_STRING[@]}"
}

nix::intern::dump() {
    nix::intern::initialize
    nix::bash::dump::variables 'RO_STRING_'
}

nix::intern::test() {
    local VALUE="$1"
    shift

    nix::intern::initialize
    nix::bash::map::test RO_STRING "${VALUE}"
}

nix::intern::add() {
    nix::intern::initialize
    
    local VALUE="$1"
    shift

    if [[ ! "${VALUE}" ]]; then
        REPLY=NIX_CONST_EMPTY
    fi

    if ! nix::intern::test "${VALUE}"; then
        local VARIABLE="RO_STRING_${#RO_STRING[@]}"
        RO_STRING["${VALUE}"]="${VARIABLE}"

        declare -gr "${VARIABLE}=${VALUE}"
    fi
    
    REPLY="${RO_STRING["${VALUE}"]}"
}
