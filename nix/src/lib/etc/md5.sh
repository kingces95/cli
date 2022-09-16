nix::md5::hash() {
    read REPLY _ < <(md5sum)
    echo "${REPLY}"
}

nix::md5::check() {
    local HASH="$1"
    shift

    md5sum --status --check <(echo "${HASH} -")
}
