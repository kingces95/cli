
nix::port::wait() {
    # https://www.golinuxcloud.com/test-ssh-connection/

    local PORT="$1"
    shift

    local HOST="${1-localhost}"
    shift

    local TIMEOUT="${1-60}"
    shift

    nix::bash::timeout "${TIMEOUT}" nix::port::test "${PORT}" "${HOST}"
}

nix::port::test() {
    local PORT="$1"
    shift

    local HOST="${1-localhost}"
    shift

    nc -z "${HOST}" "${PORT}"
}
