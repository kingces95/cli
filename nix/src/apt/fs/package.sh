nix::apt::fs::package::timestamp() {
    if [[ ! -f "${NIX_OS_APT_PACKAGE_TIMESTAMP}" ]]; then
        echo 0
        return
    fi

    nix::fs::timestamp "${NIX_OS_APT_PACKAGE_TIMESTAMP}"
}
