nix::tool::git::config::global::set() {
    local KEY="$1"
    shift

    local VALUE="$1"
    shift

    git config --global "${KEY}" "${VALUE}"
}

nix::tool::git::config::global::user_name::set() {
    nix::tool::git::config::global::set 'user.name' "${NIX_MY_DISPLAY_NAME}"
}

nix::tool::git::config::global::email::set() {
    nix::tool::git::config::global::set 'user.email' "${NIX_UPN_MICROSOFT}"
}

nix::tool::git::config::initialize() {
    nix::tool::git::config::global::user_name::set
    nix::tool::git::config::global::email::set
}

nix::tool::git::keypair::prompt_to_add() {
    local KEY="$(nix::ssh::keypair::public::cat)"
    nix::log::printf '%s'
    printf "$(nix::color::green %s)\n" "${KEY}"
    
    nix::log::prompt
        "After adding your public key (above in green) to ado (${NIX_AZURE_DEV_SSH_WWW}) hit enter to continue."
}

nix::tool::git::keypair::init() {
    if nix::ssh::keypair::test; then
        return
    fi

    nix::ssh::keypair::generate

    nix::tool::git::keypair::prompt_to_add
}

nix::tool::git::stub() {
    unset -f git

    # add ssh.dev.azure.com as known host
    cat "${NIX_AZURE_DEV_SSH_KNOWN_HOST}" \
        | pump3 nix::ssh::known_hosts::add

    # standard first time git setup
    nix::tool::git::config::initialize >/dev/null

    # add ssh key to ado
    nix::tool::git::keypair::init

    git "$@"
}
