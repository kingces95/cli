nix::bash::map::poset::total_order() { 
    local -n ADJACENCY_LIST_REF=$1
    local -A VISITED=()
    nix::bash::map::poset::total_order::recurse \
        $(nix::bash::args::sorted "${!ADJACENCY_LIST_REF[@]}")
}

nix::bash::map::poset::total_order::recurse() {
    while (( $# > 0 )); do
        local VERTEX=$1
        shift

        if nix::bash::map::test VISITED ${VERTEX}; then
            continue
        fi

        nix::bash::map::poset::total_order::recurse \
            $(nix::bash::args::sorted ${ADJACENCY_LIST_REF[${VERTEX}]})

        echo ${VERTEX}
        VISITED[${VERTEX}]=true
    done
}
