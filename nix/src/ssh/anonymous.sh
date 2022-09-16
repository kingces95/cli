alias nix-anonymous-test='nix::anonymous::test'
alias nix-anonymous-adduser='nix::anonymous::adduser'
alias nix-anonymous-deluser='nix::anonymous::deluser'
alias nix-anonymous-key-install='nix::anonymous::key::install'

nix::anonymous::test() {
    cat /etc/passwd \
        | egrep "^${VPT_ANONYMOUS}:" \
        >/dev/null 2>&1
}

nix::anonymous::adduser() {
    if nix::anonymous::test; then
        return
    fi

    sudo adduser "${VPT_ANONYMOUS}" \
        --gecos "" \
        --disabled-password \
        --quiet

    nix::anonymous::key::install

    sudo rm "/home/${VPT_ANONYMOUS}/.bash_login"

    echo "anon:asdf1234" | sudo chpasswd
}

nix::anonymous::deluser() {
    if ! nix::anonymous::test; then
        return
    fi

    sudo deluser "${VPT_ANONYMOUS}" \
        --remove-home \
        --quiet
}

nix::anonymous::key::install() {
    if [[ -f "${VPT_ANONYMOUS_AUTHORIZED_KEYS}" ]]; then
        return
    fi

    sudo mkdir -p $(dirname "${VPT_ANONYMOUS_AUTHORIZED_KEYS}")
    
    sudo cp \
        "${VPT_SSH_PUBLIC_KEY}" \
        "${VPT_ANONYMOUS_AUTHORIZED_KEYS}"
}
