alias fd-secret-azure-password="nix::secret::azure::password::get"
alias fd-secret-azure-relay-shared-access-key="nix::secret::azure::relay_shared_access_key::get"
alias fd-secret-github-recovery-codes="nix::secret::github::recovery_codes::get"
alias fd-secret-github-pat="nix::secret::github::pat::get"
alias fd-secret-github-pat-repo-scope="nix::secret::github::pat_repo_scope::get"
alias fd-secret-github-password="nix::secret::github::password::get"
alias fd-secret-github-mfa-code="nix::secret::github::mfa_code::get"

nix::secret::azure::password::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_AZURE_PASSWORD}"
}
nix::secret::azure::relay_shared_access_key::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_AZURE_RELAY_SHARED_ACCESS_KEY}"
}
nix::secret::github::recovery_codes::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_GITHUB_RECOVERY_CODES}"
}
nix::secret::github::pat::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_GITHUB_PAT}"
}
nix::secret::github::pat_repo_scope::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_GITHUB_PAT_REPO_SCOPE}"
}
nix::secret::github::password::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_GITHUB_PASSWORD}"
}
nix::secret::github::mfa_code::get() {
    nix::secret::get "${NIX_KEYVAULT_SECRET_GITHUB_MFA_CODE}"
}

nix::secret::get() (
    nix::env::tenant::switch "${NIX_PPE_NAME}" "${NIX_PERSONA_ME}"

    local NAME="$1"
    shift

    az keyvault secret show \
        --subscription "${NIX_ENV_SUBSCRIPTION}" \
        --vault-name "${NIX_KEYVAULT}" \
        --name "${NAME}" \
        --query 'value' \
        --output tsv
)
