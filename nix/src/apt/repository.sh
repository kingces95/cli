alias fd-apt-repo-cat="nix::apt::repository::cat"
alias fd-apt-repo-install="nix::apt::repository::install"
alias fd-apt-repo-uninstall="nix::apt::repository::uninstall"
alias fd-apt-repo-list="nix::apt::repository::list"

nix::apt::repository::cat() {
    local NAME="$1"
    shift

    cat "$(nix::apt::fs::repository::path ${NAME})"
}

nix::apt::repository::list() {
    nix::apt::fs::repository::list \
        | pump nix::path::file::name
}

nix::apt::repository::uninstall() {
    local NAME="$1"
    shift

    nix::sudo::rm "$(nix::apt::fs::repository::path ${NAME})"
}

nix::apt::repository::install() {
    local NAME="$1"
    shift

    local PTH="$(nix::apt::fs::repository::path ${NAME})"

    nix::sudo::register "${PTH}"
}
