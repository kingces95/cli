alias fd-tool-apt-package-name="nix::tool::apt::package::name"
alias fd-tool-apt-package-version="nix::tool::apt::package::version"
alias fd-tool-apt-package-install="nix::tool::apt::package::install"
alias fd-tool-apt-package-uninstall="nix::tool::apt::package::uninstall"

nix::tool::apt::package::name() {
    local NAME="$1"
    shift

    local PACKAGE_NAME=$(nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_PACKAGE}")
    echo "${PACKAGE_NAME:=${NAME}}"
}

nix::tool::apt::package::version() {
    local NAME="$1"
    shift

    local VERSION=$(nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_VERSION}")
    echo "${VERSION:=latest}"
}

nix::tool::apt::package::install() {
    local NAME="$1"
    shift

    local PACKAGE="$(nix::tool::apt::package::name "${NAME}")"
    local VERSION="$(nix::tool::apt::package::version "${NAME}")"

    nix::apt::package::install "${PACKAGE}" "${VERSION}"
}

nix::tool::apt::package::uninstall() {
    local NAME="$1"
    shift

    local PACKAGE="$(nix::tool::apt::package::name "${NAME}")"

    nix::apt::package::uninstall "${PACKAGE}"
}
