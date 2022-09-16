alias fd-proxy-install="nix::proxy::install"
alias fd-proxy-enable="nix::proxy::enable"
alias fd-proxy-disable="nix::proxy::disable"
alias fd-proxy-start="nix::proxy::start"
alias fd-proxy-stop="nix::proxy::stop"

nix::proxy::install() {
    if nix::proxy::test; then
        return
    fi

    (
        nix::log::subproc::begin 'nix: proxy: starting proxy'
        nix::env::tenant::switch "${NIX_PPE_NAME}"
        nix::proxy::start
    )

    nix::port::wait "${VPT_SOCKS5H_PORT}"
}

nix::proxy::enable() {
    export HTTPS_PROXY="${VPT_SOCKS5H_URL}"
}

nix::proxy::disable() {
    unset HTTPS_PROXY
}

nix::proxy::test() {
    # sudo netstat -a | egrep '(2223|2224)'
    nix::port::test "${VPT_AZURE_RELAY_LOCAL_PORT}" "${VPT_AZURE_RELAY_LOCAL_IP}" \
        && nix::port::test "${VPT_SOCKS5H_PORT}"
}

nix::proxy::start() {
    nix::ssh::key::install
    nix::azbridge::local::start::async
    nix::ssh::azure::relay::proxy::start::async
}

nix::proxy::stop() {
    # ps -aux | egrep '(ssh|azbridge)'
    killall ssh
    killall azbridge
    # sleep 2
    # killall -9 ssh
    # killall -9 azbridge
}