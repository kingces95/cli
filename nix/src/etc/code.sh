alias code-list="nix::code::list"
alias code-install="nix::code::install"
alias code-uninstall="nix::code::uninstall"
alias code-reinstall="nix::code::reinstall"

nix::code::is_installed() {
    code --list-extensions | grep "$@" >/dev/null
}
nix::code::list() {
    code --list-extensions
}
nix::code::install() {
    code --install-extension "$@"
}
nix::code::uninstall() {
    code --uninstall-extension "$@"
}
nix::code::reinstall() {
    if nix::code::is_installed "$@"; then
        nix::code::uninstall "$@"
    fi
    nix::code::install "$@"
}
