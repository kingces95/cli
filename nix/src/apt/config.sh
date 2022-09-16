nix::apt::config() {
    apt-config dump
}

nix::apt::config::hash() {
    nix::apt::config \
        | nix::md5::hash
}
