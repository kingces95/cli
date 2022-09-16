alias fd-group-x2fa-list="nix::ad::group::list '${NIX_AD_GROUP_X2FA}'"
alias fd-group-x2fa-add="nix::ad::group::add '${NIX_AD_GROUP_X2FA}'"
alias fd-group-x2fa-remove="nix::ad::group::remove '${NIX_AD_GROUP_X2FA}'"
alias fd-group-x2fa-check="nix::ad::group::check '${NIX_AD_GROUP_X2FA}'"

alias fd-group-admin-list="nix::ad::group::list '${NIX_AD_GROUP_ADMINS}'"
alias fd-group-admin-add="nix::ad::group::add '${NIX_AD_GROUP_ADMINS}'"
alias fd-group-admin-remove="nix::ad::group::remove '${NIX_AD_GROUP_ADMINS}'"
alias fd-group-admin-check="nix::ad::group::check '${NIX_AD_GROUP_ADMINS}'"

nix::ad::group::to_display_name() {
    local GROUP="$1"        # MFA-Excluded-Users
    echo "${GROUP//-/ }"    # MFA Excluded Users
}
nix::ad::group::from_display_name() {
    local GROUP="$1"        # MFA Excluded Users
    echo "${GROUP// /-}"    # MFA-Excluded-Users
}

nix::ad::group::list() {
    local GROUP="$(nix::ad::group::to_display_name $1)"
    shift

    nix::az::ad::group::member::list "${GROUP}" \
        | egrep "^${NIX_USER}[-]" \
        | nix::ad::user::upn_to_name
}

nix::ad::group::check() {
    local GROUP="$(nix::ad::group::to_display_name $1)"
    shift

    local NAME="$1"
    shift

    local ID=$(nix::ad::user::id "${NAME}")
    if ! $(nix::az::ad::group::member::check "${GROUP}" "${ID}"); then
        return 1
    fi
}

nix::ad::group::add() {
    local GROUP="$(nix::ad::group::to_display_name $1)"
    shift

    local NAME="$1"
    shift

    if nix::ad::group::check "${GROUP}" "${NAME}"; then
        return 1
    fi

    local ID=$(nix::ad::user::id "${NAME}")
    nix::az::ad::group::member::add "${GROUP}" "${ID}"
}

nix::ad::group::remove() {
    local GROUP="$(nix::ad::group::to_display_name $1)"
    shift

    local NAME="$1"
    shift

    if ! nix::ad::group::check "${GROUP}" "${NAME}"; then
        return 1
    fi

    local ID=$(nix::ad::user::id "${NAME}")
    nix::az::ad::group::member::remove "${GROUP}" "${ID}"
}
