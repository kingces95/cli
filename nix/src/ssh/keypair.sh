alias fd-ssh-keypair-path="nix::ssh::keypair::path"
alias fd-ssh-keypair-generate="nix::ssh::keypair::generate"
alias fd-ssh-keypair-remove="nix::ssh::keypair::remove"
alias fd-ssh-keypair-public-path="nix::ssh::keypair::public::path"
alias fd-ssh-keypair-public-cat="nix::ssh::keypair::public::cat"

nix::ssh::keypair::path() {
    local NAME="${1-id_rsa}"
    echo "$(nix::ssh::dir)/${NAME}"
}

nix::ssh::keypair::test() {
    [[ -f "$(nix::ssh::keypair::path)" ]]
}

nix::ssh::keypair::remove() {
    nix::fs::file::remove "$(nix::ssh::keypair::path $@)"
    nix::fs::file::remove "$(nix::ssh::keypair::public::path $@)"
}

nix::ssh::keypair::generate() {
    ssh-keygen \
        -b 2048 \
        -t rsa \
        -f "$(nix::ssh::keypair::path $@)" \
        -q \
        -N ""
}

nix::ssh::keypair::public::path() {
    local NAME="${1-id_rsa}"
    echo "$(nix::ssh::keypair::path $@).pub"
}

nix::ssh::keypair::public::cat() {
    local PTH="$(nix::ssh::keypair::public::path $@)"
    cat "${PTH}"
}
