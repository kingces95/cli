alias fd-secret-id='nix::test::keyvault::id'

nix::test::keyvault::id() {
    local NIX_AZ_KEYVAULT_SECRET_NAME="$1"
    local NIX_AZ_KEYVAULT_NAME="$2"
    local NIX_AZ_SUBSCRIPTION="$3"

    nix::az::keyvault::secret::id
}
