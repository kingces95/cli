alias fd-apt-key-install="nix::apt::pgp::install"
alias fd-apt-key-uninstall="nix::apt::pgp::uninstall"
alias fd-apt-key-list="nix::apt::pgp::list"

nix::apt::pgp::list() {
    nix::apt::fs::pgp::list \
        | pump nix::path::file::name
}

nix::apt::pgp::uninstall() {
    local NAME="$1"  # e.g. microsoft
    shift

    nix::sudo::rm "$(nix::apt::fs::pgp::path ${NAME})"
}

nix::apt::pgp::install() {
    local NAME="$1"  # e.g. microsoft
    shift

    local PTH="$(nix::apt::fs::pgp::path ${NAME})"

    # pgp -> gpg
    nix::gpg::dearmor \
        | nix::sudo::register "${PTH}"
}
