alias fd-account-admin-test="nix::account::admin::test"
alias fd-account-admin-create="nix::account::admin::create"
alias fd-account-admin-delete="nix::account::admin::delete"

alias fd-account-user-test="nix::account::user::test"
alias fd-account-user-create="nix::account::user::create"
alias fd-account-user-delete="nix::account::user::delete"

nix::account::test() {
    local NAME="$1"
    shift

    nix::ad::user::test "${NAME}"
}
nix::account::create() {
    local NAME="$1"
    shift

    nix::ad::user::create "${NAME}"
    nix::ad::group::add "${NIX_AD_GROUP_X2FA}" "${NAME}"
}
nix::account::delete() {
    local NAME="$1"
    shift

    nix::ad::user::delete "${NAME}"
}

nix::account::admin::test() {
    local NAME="${NIX_ACCOUNT_ADMIN}"
    nix::account::test "${NAME}"
}
nix::account::admin::create() {
    local NAME="${NIX_ACCOUNT_ADMIN}"
    nix::account::create "${NAME}"
    nix::ad::group::add "${NIX_AD_GROUP_ADMINS}" "${NAME}"
}
nix::account::admin::delete() {
    local NAME="${NIX_ACCOUNT_ADMIN}"
    nix::account::delete "${NAME}"
}

nix::account::user::test() {
    local NAME="${NIX_ACCOUNT_USER}"
    nix::account::test "${NAME}"
}
nix::account::user::create() {
    local NAME="${NIX_ACCOUNT_USER}"
    nix::account::create "${NAME}"
}
nix::account::user::delete() {
    local NAME="${NIX_ACCOUNT_USER}"
    nix::account::delete "${NAME}"
}
