alias fd-user-list="nix::ad::user::list"
alias fd-user-id="nix::ad::user::id"
alias fd-user-test="nix::ad::user::test"
alias fd-user-report="nix::ad::user::report | a4f"
alias fd-user-create="nix::ad::user::create"
alias fd-batch-users-list="nix::env::tenant::batch nix::ad::user::list"
alias fd-batch-users-report="nix::env::tenant::batch nix::ad::user::report | a4f | fit"

nix::ad::user::upn_to_name() {
    egrep -o "[-][a-z0-9-]*@" \
        | egrep -o "[a-z0-9][a-z0-9-]*"
}

nix::ad::user::upn() {
    local NAME="$1"
    shift

    echo "${NIX_USER}-${NAME}@${NIX_ENV_TENANT_HOST}"
}

nix::ad::user::id() {
    local NAME="$1"
    shift

    local UPN="$(nix::ad::user::upn ${NAME})"
    local ID="$(nix::az::ad::user::id ${UPN})"
    echo "${ID}"
}

nix::ad::user::test() {
    local NAME="$1"
    shift
    
    [[ "$(nix::ad::user::id ${NAME})" ]]
}

nix::ad::user::create() {
    local NAME="$1"
    shift

    if nix::ad::user::test "${NAME}"; then
        return 1
    fi

    local UPN="$(nix::ad::user::upn ${NAME})"
    nix::az::ad::user::create \
        "${UPN}" \
        "${NIX_MY_DISPLAY_NAME}" \
        "$(nix::secret::azure::password::get)" >/dev/null
}

nix::ad::user::delete() {
    local NAME="$1"
    shift

    if ! nix::ad::user::test "${NAME}"; then
        return 1
    fi

    local ID=$(nix::ad::user::id "${NAME}")
    nix::az::ad::user::delete "${ID}" >/dev/null
}

nix::ad::user::group::membership() {
    local NAME="$1"
    shift

    local ID=$(nix::ad::user::id "${NAME}")
    nix::az::ad::user::get_member_groups \
        "${ID}" \
        | sed 's/ /-/g'
}

nix::ad::user::report() {
    nix::ad::user::list \
        | pump nix::ad::user::record
}

nix::ad::user::record() {
    local NAME="$1"
    shift

    local UPN="$(nix::ad::user::upn ${NAME})"
    echo "${NAME}" "${UPN}" "$(
        nix::ad::user::group::membership "${NAME}" \
            | nix::line::join
    )"
}

nix::ad::user::list() {
    local QUERY="startswith(userPrincipalName,'${NIX_USER}-')"
    nix::az::ad::user::filter "${QUERY}" \
        | nix::ad::user::upn_to_name
}
