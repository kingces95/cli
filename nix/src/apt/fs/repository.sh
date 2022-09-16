nix::apt::fs::repository::path() {
    local NAME="$1"\
    shift
    
    echo "${NIX_OS_APT_DIR_SOURCES}/${NAME}.list"
}

nix::apt::fs::repository::list() {
    find  "${NIX_OS_APT_DIR_SOURCES}" \
        -name "*.list" \
        -type f
}

nix::apt::fs::repository::nodes() {
    echo "${NIX_OS_DIR_APT}/sources.list"
    find "${NIX_OS_APT_DIR_SOURCES}"
}

nix::apt::fs::repository::timestamp() {
    nix::apt::fs::repository::nodes \
        | pump nix::fs::timestamp \
        | nix::line::max
}
