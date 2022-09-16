alias fd-ssh-known-hosts-path="nix::ssh::known_hosts::path"
alias fd-ssh-known-hosts-cat="nix::ssh::known_hosts::cat"
alias fd-ssh-known-hosts-key-list="nix::ssh::known_hosts::key::list"
alias fd-ssh-known-hosts-key-test="nix::ssh::known_hosts::key::test"
alias fd-ssh-known-hosts-clear="nix::ssh::known_hosts::clear"
alias fd-ssh-known-hosts-scan="nix::ssh::known_hosts::scan"
alias fd-ssh-known-hosts-add="nix::ssh::known_hosts::add"
alias fd-ssh-known-hosts-scan-and-add="nix::ssh::known_hosts::scan_and_add"

nix::ssh::known_hosts::path() {
    echo "${NIX_OS_SSH_KNOWN_HOSTS}"
}

nix::ssh::known_hosts::cat() {
    cat "$(nix::ssh::known_hosts::path)"
}

nix::ssh::known_hosts::key::list() {
    nix::ssh::known_hosts::cat \
        | nix::record::project 3 3
}

nix::ssh::known_hosts::key::test() {
    local KEY="$1"
    shift
    
    nix::ssh::known_hosts::cat \
        | nix::record::contains 3 "${KEY}" 3
}

nix::ssh::known_hosts::clear() {
    local PTH="$(nix::ssh::known_hosts::path)"
    nix::fs::file::remove "${PTH}"
    touch "${PTH}"
}

nix::ssh::known_hosts::scan_and_add() {
    nix::ssh::known_hosts::scan "$@" 2>/dev/null \
        | pump3 nix::ssh::known_hosts::add \
        
}

nix::ssh::known_hosts::scan() {
    local HOST="$1"
    
    ssh-keyscan \
        -t rsa \
        "${HOST}"
}

nix::ssh::known_hosts::add() {
    local HOST="$1"
    shift
    
    local TYPE="$1"
    shift
    
    local KEY="$1"
    shift
    
    if nix::ssh::known_hosts::key::test "${KEY}"; then
        return
    fi  

    echo "${HOST}" "${TYPE}" "${KEY}" \
        >> "$(nix::ssh::known_hosts::path)"
}
