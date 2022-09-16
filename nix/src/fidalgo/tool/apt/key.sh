alias fd-tool-apt-key-url="nix::tool::apt::key::url"
alias fd-tool-apt-key-asc="nix::tool::apt::key::asc"
alias fd-tool-apt-key-install="nix::tool::apt::key::install"
alias fd-tool-apt-key-uninstall="nix::tool::apt::key::uninstall"

nix::tool::apt::key::url() {
    local NAME="$1"
    shift

    nix::tool::apt::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_KEY}"
}

nix::tool::apt::key::test() {
    local NAME="$1"
    shift
    
    local URL="$(nix::tool::apt::key::url "${NAME}")"

    [[ "${URL}" ]]
}

nix::tool::apt::key::asc() {
    local NAME="$1"
    shift

    local URL="$(nix::tool::apt::key::url "${NAME}")"
    local EXT="$(nix::path::file::extension ${URL})"

    nix::curl "${URL}" \
        | case "${EXT}" in
            'asc') cat ;;
            'gpg') nix::gpg::armor ;;
            *) 
                echo "Bad key url '${URL}'." >&2
                return 1
        esac
}

nix::tool::apt::key::install() {
    local NAME="$1"
    shift

    if ! nix::tool::apt::key::test "${NAME}"; then
        return
    fi

    nix::tool::apt::key::asc "${NAME}" \
        | nix::gpg::dearmor \
        | nix::apt::pgp::install "${NAME}"
}

nix::tool::apt::key::uninstall() {
    local NAME="$1"
    shift

    if ! nix::tool::apt::key::test "${NAME}"; then
        return
    fi

    nix::apt::pgp::uninstall "${NAME}"
}
