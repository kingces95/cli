alias fd-tool-apt-rows="nix::tool::apt::rows"
alias fd-tool-apt-list="nix::tool::apt::list"
alias fd-tool-apt-test="nix::tool::apt::test"
alias fd-tool-apt-install="nix::tool::apt::package::install"
alias fd-tool-apt-uninstall="nix::tool::apt::package::uninstall"
alias fd-tool-apt-scorch="nix::tool::apt::scorch"

nix::tool::apt::rows() {
    nix::tool::cat \
        | nix::table::filter::match '' 2
    nix::tool::cat \
        | nix::table::filter::match 'apt' 2
}

nix::tool::apt::list() {
    nix::tool::apt::rows \
        | nix::table::project 1
}

nix::tool::apt::lookup() {
    local NAME="$1"
    shift

    nix::tool::apt::rows \
        | nix::table::vlookup "${NAME}" "$@"
}

nix::tool::apt::test() {
    local NAME="$1"
    shift

    nix::tool::apt::list \
        | nix::table::contains "${NAME}"
}

nix::tool::apt::reinstall() {
    nix::tool::apt::uninstall "$@"
    nix::tool::apt::install "$@"
}

nix::tool::apt::install() {
    local NAME="$1"
    shift

    if nix::which::test "${NAME}"; then
        return
    fi

    nix::tool::apt::key::install "${NAME}"
    nix::tool::apt::repository::install "${NAME}"
    nix::tool::apt::package::install "${NAME}"
}

nix::tool::apt::uninstall() {
    local NAME="$1"
    shift

    if ! nix::which::test "${NAME}"; then
        return
    fi

    nix::tool::apt::key::uninstall "${NAME}"
    nix::tool::apt::repository::uninstall "${NAME}"
    nix::tool::apt::package::uninstall "${NAME}"
}

nix::tool::apt::scorch() {
    nix::sudo::login

    nix::tool::apt::list \
        | pump nix::tool::apt::repository::uninstall \
        > /dev/null 2>/dev/null

    nix::tool::apt::list \
        | pump nix::tool::apt::key::uninstall \
        > /dev/null 2>/dev/null

    nix::tool::apt::clean
}

nix::tool::apt::clean() {
    nix::apt::sudo::clean
}
