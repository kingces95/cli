alias az-extension-install="nix::az::extension::upgrade"
alias az-extension-curl="nix::az::extension::curl"
alias az-extension-uninstall="nix::az::extension::uninstall"
alias az-extension-is-installed="nix::az::extension::is_installed"

nix::az::extension::curl() {
    local SOURCE="$1"
    shift

    local DEST="/tmp/${FILE}"

    if [[ ! -f "${DEST}" ]]; then
        curl -s "${SOURCE}" -o "${DEST}"
    fi

    nix::az::extension::upgrade::source "${DEST}" 2>/dev/null
}

nix::az::extension::is_installed() {
    local NAME="$1"
    shift

    local VERSION="$1"
    shift

    local ACTUAL_VERSION=$(nix::az::extension::which "${NAME}")

    if [[ "${VERSION}" ]]; then
        [[ "${ACTUAL_VERSION}" == "${VERSION}" ]]
    else
        [[ "${ACTUAL_VERSION}" ]]
    fi
}

nix::az::extension::uninstall() {
    local NAME="$1"
    shift

    if nix::az::extension::is_installed "${NAME}"; then
        nix::az::extension::remove "${NAME}"
    fi
}

