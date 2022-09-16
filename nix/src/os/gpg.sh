alias fd-gpg-dearmor='nix::gpg::dearmor'
alias fd-gpg-armor='nix::gpg::armor'

nix::gpg::dearmor() {
    gpg --dearmor
}

nix::gpg::armor() {
    local KEYRING="$(mktemp /tmp/XXX.gpg)"
    cat > "${KEYRING}"

    gpg \
        --export \
        --keyring "${KEYRING}" \
        --armor

    rm "${KEYRING}"
}

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
# sudo apt-get install -y gpg
# wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.asc.gpg
# sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
# wget https://packages.microsoft.com/config/ubuntu/{os-version}/prod.list
# sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
# sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
# sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
