nix::table::pump() {
    local FUNC="$1"
    shift

    while read -a MAPFILE; do
        "${FUNC}" "$@"
    done    
}

nix::table::take() {
    if ! read; then
        return
    fi
    
    echo "${REPLY}"
}

nix::table::filter::match() {
    nix::table::pump \
        nix::row::filter::match "$@"
}

nix::table::filter::glob() {
    nix::table::pump \
        nix::row::filter::glob "$@"
}

nix::table::filter::regex() {
    nix::table::pump \
        nix::row::filter::regex "$@"
}

nix::table::first() {
    nix::table::filter::match "$@" \
        | nix::table::take
}

nix::table::contains() {
    read < <(nix::table::first "$@")
}

nix::table::project() {
    nix::table::pump \
        nix::row::project "$@"
}

nix::table::shift() {
    nix::table::pump \
        nix::row::shift "$@"
}

nix::table::number() {
    nl | nix::table::pump \
        nix::row::trim "$@"
}

nix::table::swap() {
   nix::table::pump \
        nix::row::swap "$@"
}

nix::table::promote() {
    nix::table::pump \
        nix::row::promote "$@"
}

nix::table::replace() {
    nix::table::pump \
        nix::row::replace "$@"
}

nix::table::copy() {
    nix::table::pump \
        nix::row::copy "$@"
}

nix::line::error_if_none() {
    if ! read; then
        return 1
    fi

    echo "${REPLY}"
    
    cat 
}

nix::table::vlookup() {
    local KEY="$1"
    shift

    nix::table::filter::match "${KEY}" \
        | nix::table::project "$@" \
        | nix::line::error_if_none
}
