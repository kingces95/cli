alias fd-azbridge-remote-start='nix::azbridge::remote::start'
alias fd-azbridge-local-start='nix::azbridge::local::start'
alias fd-azbridge-remote-start-async='nix::azbridge::remote::start::async'
alias fd-azbridge-local-start-async='nix::azbridge::local::start::async'

nix::azbridge() {
    local RELAY_CONNECTION_STRING=$(nix::azure::relay::connection_string)

    if "${VPT_AZBRIDGE_ASYNC-false}"; then
        azbridge "$@" -x "${RELAY_CONNECTION_STRING}" &
        return
    fi

    azbridge "$@" -x "${RELAY_CONNECTION_STRING}"
}

nix::azbridge::local::start() {
    # azbridge localhost:2223:bridge
    nix::azbridge \
        -L "${VPT_AZURE_RELAY_LOCAL_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}:${VPT_AZURE_RELAY_NAME}"
}

nix::azbridge::remote::start() {
    nix::port::wait "${VPT_SSH_PORT}" localhost 
    # azbridge bridge:localhost:2223/2222
    nix::azbridge \
        -R "${VPT_AZURE_RELAY_NAME}:${VPT_AZURE_RELAY_REMOTE_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}/${VPT_AZURE_RELAY_REMOTE_PORT}"
}

nix::azbridge::local::start::async() {
    VPT_AZBRIDGE_ASYNC=true \
        nix::azbridge::local::start
}

nix::azbridge::remote::start::async() {
    VPT_AZBRIDGE_ASYNC=true \
        nix::azbridge::remote::start
}
