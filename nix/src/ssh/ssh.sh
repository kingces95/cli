alias fd-ssh-dir="nix::ssh::dir"
alias fd-ssh-ls="nix::ssh::ls"
alias fd-ssh-start="nix::ssh::start"

nix::ssh::dir() {
    echo "${NIX_HOME_DIR_SSH}"
}

nix::ssh::ls() {
    ll "$(nix::ssh::dir)"
}

nix::ssh::start() (
    nix::tool::install sshd

    # hack
    sudo mkdir -p /var/run/sshd
    sudo sed -i 's/session\s*required\s*pam_loginuid\.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd
    sudo sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo sed -i -E "s/#*\s*Port\s+.+/Port ${VPT_SSH_PORT}/g" /etc/ssh/sshd_config
    # Need to UsePAM so /etc/environment is processed
    sudo sed -i -E "s/#?\s*UsePAM\s+.+/UsePAM yes/g" /etc/ssh/sshd_config

    sudo /etc/init.d/ssh start
)

nix::ssh() {
    ssh \
        "${VPT_SSH_DEFAULTS[@]}" \
        "$@" \
        "${VPT_ANONYMOUS_UPN}"
}

nix::ssh::uup() {
    local PORT="$1"
    shift

    local TIMEOUT="${1-${VPT_SSH_TIMEOUT}}"
    shift

    nix::bash::timeout "${TIMEOUT}" \
        ssh \
            "${VPT_SSH_DEFAULTS[@]}" \
            -q \
            -p "${PORT}" \
            "${VPT_ANONYMOUS_UPN}" \
            'exit 0'
}

nix::ssh::proxy::start() (
    nix::ssh::uup "${VPT_SSH_PORT}"

    nix::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_SSH_PORT}" -vvv \
        -i ~/.ssh/id_rsa
)

nix::ssh::azure::relay::connect() {
    nix::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"

    nix::ssh \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}"
}

nix::ssh::azure::relay::proxy::start() (
    # https://www.metahackers.pro/ssh-tunnel-as-socks5-proxy/

    nix::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    nix::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N
)

nix::ssh::azure::relay::proxy::start::async() {
    nix::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    nix::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N \
        &
}

nix::ssh::key::install() {
    if [[ -f "{VPT_USER_PRIVATE_KEY}" ]]; then
        return
    fi

    mkdir -p "$(dirname "${VPT_USER_PRIVATE_KEY}")"

    # authenticate clients by private key
    # sshd is very particular about the permissions of this file
    install -m u=rw,go= \
        "${VPT_SSH_PRIVATE_KEY}" \
        "${VPT_USER_PRIVATE_KEY}"
}

nix::jobs::stop() {
    while kill -9 % >/dev/null 2>&1; do
        sleep 1
    done
}