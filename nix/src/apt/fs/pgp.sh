nix::apt::fs::pgp::path() {
    local NAME="$1"\
    shift
    
    echo "${NIX_OS_APT_DIR_TRUSTED}/${NAME}.gpg"
}

nix::apt::fs::pgp::list() {
    find "${NIX_OS_APT_DIR_TRUSTED}" \
        -type f
}

nix::apt::fs::pgp::nodes() {
    find "${NIX_OS_APT_DIR_TRUSTED}"
}

nix::apt::fs::pgp::timestamp() {
    nix::apt::fs::pgp::nodes \
        | pump nix::fs::timestamp \
        | nix::line::max
}
