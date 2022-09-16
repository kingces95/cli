alias fd-tool-deb-rows="nix::tool::deb::rows"
alias fd-tool-deb-list="nix::tool::deb::list"
alias fd-tool-deb-test="nix::tool::deb::test"
alias fd-tool-deb-package="nix::tool::deb::package"
alias fd-tool-deb-url="nix::tool::deb::url"
alias fd-tool-deb-install="nix::tool::deb::install"
alias fd-tool-deb-uninstall="nix::tool::deb::uninstall"

nix::tool::deb::rows() {
    nix::tool::cat \
        | nix::table::filter::match 'deb' 2
}

nix::tool::deb::list() {
    nix::tool::deb::rows \
        | nix::table::project 1
}

nix::tool::deb::lookup() {
    local NAME="$1"
    shift

    nix::tool::deb::rows \
        | nix::table::vlookup "${NAME}" "$@"
}

nix::tool::deb::test() {
    local NAME="$1"
    shift

    nix::tool::deb::list \
        | nix::table::contains "${NAME}"
}

nix::tool::deb::package() {
    local NAME="$1"
    shift

    nix::tool::deb::lookup "${NAME}" "${NIX_TOOL_DEB_FIELD_PACKAGE}"
}

nix::tool::deb::url() {
    local NAME="$1"
    shift

    nix::tool::deb::lookup "${NAME}" "${NIX_TOOL_DEB_FIELD_URL}"
}

nix::tool::deb::install() (
    local NAME="$1"
    shift

    if nix::which::test "${NAME}"; then
        return
    fi

    cd /tmp
    local PACKAGE="$(nix::tool::deb::package "${NAME}")"
    local URL="$(nix::tool::deb::url "${NAME}")"

    (
        nix::log::subproc::begin "nix: apt: deb: downloading ${PACKAGE}"
        curl \
            --silent \
            --location \
            --remote-header-name \
            --remote-name "${URL}"
    )

    (
        nix::log::subproc::begin "nix: apt: deb: installing ${NAME}"
        sudo apt-get install \
            -qq \
            "./${PACKAGE}"
    )
)

nix::tool::deb::uninstall() (
    local NAME="$1"
    shift

    if ! nix::which::test "${NAME}"; then
        return
    fi

    local PACKAGE="$(nix::tool::deb::package "${NAME}")"

    sudo apt-get remove \
        -qq \
        "${NAME}"
)
