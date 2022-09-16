alias fd-graph-print="nix::graph::print"
alias fd-graph-post-order="nix::graph::walk::post_order"

nix::graph::print() {
    local DEPTH FUNC
    while read -r DEPTH FUNC; do
        echo "$(nix::string::indent ${DEPTH})${FUNC}"
    done
}

nix::graph::walk::post_order() {
    local -A ADJACENCY_LIST=()
    nix::bash::map::read_list ADJACENCY_LIST

    local -A VISITED=()
    nix::graph::walk::post_order::recurse 0 "$@"
}

nix::graph::walk::post_order::recurse() {
    local -i DEPTH="$1"
    shift

    local CHILD_DEPTH=$(( DEPTH + 1 ))
    local VERTEX
    for VERTEX in "$@"; do

        # skip if vertex previously processed
        if nix::bash::map::test VISITED "${VERTEX}"; then
            continue
        fi
        VISITED[${VERTEX}]=true

        # process vertex
        echo "${DEPTH} ${VERTEX}"

        # process children
        nix::graph::walk::post_order::recurse "$CHILD_DEPTH" \
            $(nix::bash::args::sorted ${ADJACENCY_LIST[${VERTEX}]})
    done
}
