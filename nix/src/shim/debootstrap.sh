alias fd-dbs-clean="nix::debootstrap::clean"

alias fd-dbs-packed-tarball="nix::debootstrap::packed::tarball"
alias fd-dbs-packed-test="nix::debootstrap::packed::test"
alias fd-dbs-packed-download="nix::debootstrap::packed::download"
alias fd-dbs-packed-packed="nix::debootstrap::packed::unpack"
alias fd-dbs-packed-rm="nix::debootstrap::packed::rm"

alias fd-dbs-unpacked-dir="nix::debootstrap::unpacked::dir"
alias fd-dbs-unpacked-test="nix::debootstrap::unpacked::test"
alias fd-dbs-unpacked="nix::debootstrap::unpacked"
alias fd-dbs-unpacked-rm="nix::debootstrap::unpacked::rm"

nix::debootstrap::packed::tarball() {
    local SUITE="$1"
    shift
    
    echo "${HOME}/debootstrap-${SUITE}.tgz"
}

nix::debootstrap::unpacked::dir() {
    local SUITE="$1"
    shift
    
    echo "${HOME}/debootstrap-${SUITE}"
}

nix::debootstrap::packed::test() {
    local SUITE="$1"
    shift

    local TARBALL="$(nix::debootstrap::packed::tarball "${SUITE}")"
    [[ -f "${TARBALL}" ]]
}

nix::debootstrap::unpacked::test() {
    local SUITE="$1"
    shift

    local UNPACKED="$(nix::debootstrap::unpacked::dir "${SUITE}")"
    [[ -d "${UNPACKED}" ]]
}

nix::debootstrap::packed::download() {
    local SUITE="$1"
    shift

    if nix::debootstrap::packed::test "${SUITE}"; then
        return
    fi

    local TEMP=$(mktemp -u)
    mkdir "${TEMP}"

    local TARBALL="$(nix::debootstrap::packed::tarball "${SUITE}")"
    sudo debootstrap \
        --make-tarball=${TARBALL} \
        "${SUITE}" \
        "${TEMP}"
}

nix::debootstrap::packed::unpack() {
    local SUITE="$1"
    shift

    if nix::debootstrap::unpacked::test "${SUITE}"; then
        return
    fi

    local UNPACKED="$(nix::debootstrap::unpacked::dir ${SUITE})"
    mkdir -p "${UNPACKED}"

    local TARBALL="$(nix::debootstrap::packed::tarball "${SUITE}")"
    sudo debootstrap \
        --unpack-tarball=${TARBALL} \
        "${SUITE}" \
        "${UNPACKED}"
}

nix::debootstrap::packed::rm() {
    local SUITE="$1"
    shift

    local TARBALL="$(nix::debootstrap::packed::tarball "${SUITE}")"
    if [[ ! -f "${TARBALL}" ]]; then
        return
    fi
    
    sudo rm -f "${TARBALL}"
}

nix::debootstrap::unpacked::rm() {
    local SUITE="$1"
    shift

    local UNPACKED="$(nix::debootstrap::unpacked::dir ${SUITE})"
    if [[ ! -d "${UNPACKED}" ]]; then
        return
    fi

    sudo rm -f -r "${UNPACKED}"
}

nix::debootstrap::clean() {
    local SUITE="$1"
    shift

    nix::debootstrap::unpacked::rm "${SUITE}"
    nix::debootstrap::packed::rm "${SUITE}"
}
