alias fd-apt-package-install="nix::apt::package::install"
alias fd-apt-package-uninstall="nix::apt::package::uninstall"
alias fd-apt-package-reinstall="nix::apt::package::reinstall"

nix::apt::package::reinstall() {
    nix::apt::package::uninstall "$@"
    nix::apt::package::install "$@"
}

nix::apt::package::install() {   
    local PACKAGE="$1"
    shift

    local VERSION="$1"
    shift

    nix::apt::update

    (
        nix::log::subproc::begin "nix: apt: installing ${PACKAGE} (${VERSION})"
        nix::apt::sudo::install "${PACKAGE}" "${VERSION}"
    )
}

nix::apt::package::uninstall() {
    local PACKAGE="$1"
    shift

    nix::log::begin "nix: apt: uninstalling ${PACKAGE}"
    nix::apt::sudo::purge "${PACKAGE}"
    nix::log::end
}
