
nix::shell::pushd() {
    command pushd "$@" >/dev/null 2>&1
}

nix::shell::popd() {
    command popd "$@" >/dev/null 2>&1
}

nix::shell::browser::open() {
    wslview "$@"
}
