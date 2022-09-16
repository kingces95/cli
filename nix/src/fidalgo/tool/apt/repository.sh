alias fd-tool-apt-repo-component="nix::tool::apt::repository::component"
alias fd-tool-apt-repo-distro="nix::tool::apt::repository::distro"
alias fd-tool-apt-repo-url="nix::tool::apt::repository::url"
alias fd-tool-apt-repo-install="nix::tool::apt::repository::install"
alias fd-tool-apt-repo-uninstall="nix::tool::apt::repository::uninstall"

nix::tool::apt::repository::component() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_REPOSITORY}"
}

nix::tool::apt::repository::distro() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_DISTRO}"
}

nix::tool::apt::repository::url() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_URL}"
}

nix::tool::apt::repository::test() {
    local NAME="$1"
    shift
    
    local URL="$(nix::tool::apt::repository::url "${NAME}")"

    [[ "${URL}" ]]
}

nix::tool::apt::repository::install::well_known() {
    local REPOSITORY="$1"
    shift

    nix::tool::install add-apt-repository
    
    (
        nix::log::subproc::begin "nix: apt: repository: installing ${REPOSITORY}"
        sudo add-apt-repository -y "${REPOSITORY}"
    )
}

nix::tool::apt::repository::install() {
    local NAME="$1"
    shift

    local REPOSITORY="$(nix::tool::apt::repository::component "${NAME}")"

    if [[ "${REPOSITORY}" == 'universe' ]]; then
        nix::tool::apt::repository::install::well_known 'universe'

    elif [[ "${REPOSITORY}" == 'multiverse' ]]; then
        nix::tool::apt::repository::install::well_known 'multiverse'

    elif nix::tool::apt::repository::test "${NAME}"; then

        local DISTRO="$(nix::tool::apt::repository::distro "${NAME}")"
        local URL="$(nix::tool::apt::repository::url "${NAME}")"

        local ENTRY=(
            'deb'
            "[arch=$(dpkg --print-architecture)]"
            "${URL}"
            "${DISTRO}"
            "${REPOSITORY}"
        )

        echo "${ENTRY[@]}" \
            | nix::apt::repository::install "${NAME}"
    fi
}

nix::tool::apt::repository::uninstall() {
    local NAME="$1"
    shift

    if ! nix::tool::apt::repository::test "${NAME}"; then
        return
    fi

    nix::apt::repository::uninstall "${NAME}"
}
