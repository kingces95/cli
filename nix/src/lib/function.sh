alias fd-function-callee-tree="nix::function::callee::tree"
alias fd-function-caller-tree="nix::function::caller::tree"
alias fd-function-callees="nix::function::callsites"
alias fd-function-body="nix::function::body"

nix::function::roots() {
    alias \
        | nix::function::match
}

nix::function::list() {
    nix::bash::dump::functions '^nix::'
}

nix::function::dump() {
    local NAME="$1"
    shift

    declare -f "${NAME}"
}

nix::function::body() {
    local NAME="$1"
    shift

    nix::function::dump "${NAME}" \
        | nix::line::skip
}

nix::function::match() {
    egrep -o 'nix(::\w+)+' \
        | sort -u
}

nix::function::callsites() {
    local NAME="$1"
    shift

    nix::function::body "${NAME}" \
        | nix::function::match
}

nix::function::adjacent() {
    local NAME="$1"
    shift
    
    nix::function::callsites "${NAME}" \
        | nix::record::prepend "${NAME}"
}

nix::function::graph() {
    nix::function::list \
        | pump nix::function::adjacent
}

nix::function::caller::tree() {
    local NAME="$1"
    shift

    nix::function::graph \
        | nix::record::swap 2 1 2 \
        | nix::graph::walk::post_order "${NAME}" \
        | nix::graph::print
}

nix::function::callee::tree() {
    local NAME="$1"
    shift

    nix::function::graph \
        | nix::graph::walk::post_order "${NAME}" \
        | nix::graph::print
}
