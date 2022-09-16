alias fd-sudo="nix::sudo"
alias fd-sudo-test="nix::sudo::test"
alias fd-sudo-login="nix::sudo::login"
alias fd-sudo-logout="nix::sudo::logout"

nix::sudo() (
    sudo "$@"
)

nix::sudo::test() {
    [[ "$EUID" = 0 ]] || sudo -n true 2>/dev/null
}

nix::sudo::logout() {
    sudo -k
}

nix::sudo::login() {
    nix::sudo true
}

nix::sudo::gpg::dearmor() {
    nix::apt::sudo::install 'gpg' > /dev/null
    nix::gpg::dearmor 
}

nix::sudo::chown::root() {
    local PTH="$1"
    shift

    nix::sudo chown root:root "${PTH}"
}

nix::sudo::chmod::readable() {
    local PTH="$1"
    shift

    nix::sudo chmod +r "${PTH}"
}


nix::sudo::rm() {
    local TARGET="$1"
    shift

    nix::sudo rm "${TARGET}"
}

nix::sudo::mv() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    nix::sudo mv "${SOURCE}" "${DESTINATION}"
}

nix::sudo::cp() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    nix::sudo cp "${SOURCE}" "${DESTINATION}"
}

nix::sudo::write() {
    local PTH="$1"
    shift

    nix::sudo tee "${PTH}" >/dev/null
    nix::sudo::chmod::readable "${PTH}"
}

nix::sudo::touch() {
    local PTH="$1"
    shift

    nix::sudo touch "${PTH}"
    nix::sudo::chmod::readable "${PTH}"
}

nix::sudo::register() {
    local PTH="$1"
    shift

    nix::sudo::write "${PTH}"
    nix::sudo::chown::root "${PTH}"
}
