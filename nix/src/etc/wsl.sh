nix::wsl::conf::cat() {
    :
}

nix::wsl::conf::unregister() {
    nix::sudo::rm "${NIX_OS_WSL_CONF}" 
}

nix::wsl::conf::register() {
    nix::wsl::conf::cat \
        | nix::sudo::register "${NIX_OS_WSL_CONF}"
}
