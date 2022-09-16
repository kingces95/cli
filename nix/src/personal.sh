alias fd-personal-secret="nix::personal::keyvault::get"
alias fd-personal-secret-id-rsa="nix::personal::id_rsa::get"
alias fd-personal-secret-id-rsa-pub="nix::personal::id_rsa_pub::get"
alias fd-personal-secret-ssh-install="nix::personal::ssh::install"

nix::personal::login() {
    local ARGS=(
        "${NIX_PERSONAL_UPN}"
        "${NIX_PERSONAL_TENANT}"
        "${NIX_PERSONAL_CLOUD}"
        "${NIX_PERSONAL_CLOUD_ENDPOINTS}"
        "${NIX_PERSONAL_SUBSCRIPTION}"
        "${NIX_PERSONAL_SUBSCRIPTION_NAME}"
        "${NIX_PERSONAL_RESOURCE_GROUP}"
        "${NIX_PERSONAL_LOCATION}"
    )

    nix::azure::tenant::login \
        "${ARGS[@]}"
}

nix::personal::group::create() {
    az group create \
        --subscription "${NIX_PERSONAL_SUBSCRIPTION}" \
        --name "${NIX_PERSONAL_RESOURCE_GROUP}" \
        --location "${NIX_PERSONAL_LOCATION}"
}

nix::personal::keyvault::create() {
    az keyvault create \
        --subscription "${NIX_PERSONAL_SUBSCRIPTION}" \
        "${NIX_PERSONAL_RESOURCE_GROUP}" \
        --location "${NIX_PERSONAL_LOCATION}"
}

nix::personal::keyvault::show() {
    az keyvault show \
        --subscription "${NIX_PERSONAL_SUBSCRIPTION}" \
        --name "${NIX_PERSONAL_KEYVAULT}"
}

nix::personal::keyvault::set() {
    local NAME="$1"
    shift

    local VALUE="$1"
    shift

    az keyvault secret set \
        --subscription "${NIX_PERSONAL_SUBSCRIPTION}" \
        --vault-name "${NIX_PERSONAL_KEYVAULT}" \
        --name "${NAME}" \
        --value "${VALUE}"
}

nix::personal::keyvault::get() {
    local NAME="$1"
    shift

    az keyvault secret show \
        --subscription "${NIX_PERSONAL_SUBSCRIPTION}" \
        --vault-name "${NIX_PERSONAL_KEYVAULT}" \
        --name "${NAME}" \
        --query 'value' \
        --output tsv
}

nix::personal::id_rsa::get() {
    nix::personal::keyvault::get "${NIX_PERSONAL_KEYVAULT_ID_RSA}" \
        | tr ' ' '\n'
}

nix::personal::id_rsa_pub::get() {
    nix::personal::keyvault::get "${NIX_PERSONAL_KEYVAULT_ID_RSA_PUB}"
}

nix::personal::ssh::install() {
    local SSH_DIR="${HOME}/.ssh"
    local SSH_ID_RSA="${SSH_DIR}/id_rsa"
    local SSH_ID_RSA_PUB="${SSH_DIR}/id_rsa.pub"

    if [ ! -d "${SSH_DIR}" ]; then
        mkdir -p "${SSH_DIR}"
    fi

    nix::personal::id_rsa_pub::get > "${SSH_ID_RSA_PUB}"

    echo '-----BEGIN OPENSSH PRIVATE KEY-----' > "${SSH_ID_RSA}"
    nix::personal::id_rsa::get >> "${SSH_ID_RSA}"
    echo '-----END OPENSSH PRIVATE KEY-----' >> "${SSH_ID_RSA}"

    # only owner should be able to read/write private key
    chmod a= "${SSH_ID_RSA}"
    chmod u=rw "${SSH_ID_RSA}"
}
