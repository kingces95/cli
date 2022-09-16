nix::shim::main() {
    local ALIAS="$(nix::shim::my_alias)"
    local GITHUB_ALIAS="$(nix::shim::my_github_alias)"

    if ! $(which gh >/dev/null); then
        nix::shim::install_github_cli
    fi

    # load user alias
    if [[ ! "${ALIAS}" ]] || [[ ! "${GITHUB_ALIAS}" ]]; then
        nix::shim::user::prompt
        ALIAS="$(nix::shim::my_alias)"
        GITHUB_ALIAS="$(nix::shim::my_github_alias)"
    fi

    # initialize deboostrap
    if ! nix::chroot::test; then
        nix::shim::debootstrap::initialize
        local UNPACKED=$(nix::debootstrap::unpacked::dir "${NIX_UBUNTU_CODENAME}")
        if [[ ! -d "${UNPACKED}" ]]; then
            echo "Debootstrap failed to unpack ${NIX_UBUNTU_CODENAME} at ${UNPACKED}"
            return
        fi
    fi

    # initialize chroot
    nix::chroot::initialize "${UNPACKED}"
    nix::shim::chroot::user::add "${ALIAS}"

    local EXIT_CODE
    while true; do
        nix::shim::chroot::main "${ALIAS}" "$@"
        EXIT_CODE=$?

        if (( EXIT_CODE == NIX_EXIT_RELOAD )); then
            continue
        fi

        if (( EXIT_CODE == NIX_EXIT_CHROOT_REINITIALIZE )); then
            nix::chroot::remove
            nix::chroot::initialize "${UNPACKED}"
            nix::shim::chroot::user::add "${ALIAS}"
            continue
        fi

        if (( EXIT_CODE == NIX_EXIT_CHROOT_REMOVE )); then
            nix::chroot::remove
            return "${NIX_EXIT_REMAIN}" 
        fi

        break
    done

    return "${EXIT_CODE}"
}

nix::shim::install_github_cli() (
    nix::log::subproc::begin 'nix: shim: apt: installing gh'
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh    
)

nix::shim::chroot::main() (
    : "${NIX_CHROOT_DIR?}"
    
    local ALIAS="$1"
    shift

    nix::chroot::mount
    trap "nix::chroot::umount" EXIT 

    local CMD=(
        'sudo' 'chroot' "${NIX_CHROOT_DIR}" 'su' '--login' "${ALIAS}"
    )

    # automated
    if (( $# > 0 )); then
        "${CMD[@]}" < <(echo "$@")
        return $?
    fi

    "${CMD[@]}"
)

nix::shim::debootstrap::initialize() {

    # download
    nix::debootstrap::packed::test "${NIX_UBUNTU_CODENAME}" || (
        nix::log::subproc::begin "nix: shim: debootstrap: download ${NIX_UBUNTU_CODENAME}"
        nix::debootstrap::packed::download "${NIX_UBUNTU_CODENAME}"
    )

    # unpack
    nix::debootstrap::unpacked::test "${NIX_UBUNTU_CODENAME}" || (
        nix::log::subproc::begin "nix: shim: debootstrap: unpack ${NIX_UBUNTU_CODENAME}"
        nix::debootstrap::packed::unpack "${NIX_UBUNTU_CODENAME}"
    )
}

nix::shim::export::emit() (

    declare -p \
        | grep NIX \
        | egrep '(-rx|-x)' \
        | egrep -v 'NIX_CODESPACE' \
        | sed 's/-rx/-r/g' \
        | sed 's/-x/-r/g' \
        | sed "s+${NIX_HOST_ROOT_DIR}+${NIX_ROOT_DIR}+g"
)

nix::shim::chroot::user::add() (
    local ALIAS="$1"
    shift

    if nix::chroot::user::test "${ALIAS}"; then
        return
    fi

    nix::log::subproc::begin "nix: shim: user: adding ${ALIAS}"
    nix::chroot::user::add "${ALIAS}"
)

nix::shim::codespace::test() {
    [[ "${USER}" == 'codespace' ]] \
        || [[ "${USER}" == 'vscode' ]]
}

nix::shim::my_alias() {
    if nix::shim::codespace::test; then
        cat "${NIX_GITHUB_USER_RECORDS}" \
            | awk -v key="${GITHUB_USER}" '$1==key {print $2}'
        return
    fi

    echo "${USER}"
}

nix::shim::my_github_alias() {
    if nix::shim::codespace::test; then
        echo "${GITHUB_USER}"
        return
    fi

    cat "${NIX_GITHUB_USER_RECORDS}" \
        | awk -v key="${USER}" '$2==key {print $1}'
}

nix::shim::ip_allocate() {
    local IP_ALLOCATION
    while true; do
        local ALLOCATION=$(( $RANDOM % 100 + 100 ))
        IP_ALLOCATION="10.${ALLOCATION}.0.0/16"

        if ! cat "${NIX_IP_ALLOCATION_RECORDS}" \
            | grep "${IP_ALLOCATION}" >/dev/null
        then
            break
        fi
    done

    echo "${IP_ALLOCATION}"
}

nix::shim::user::prompt() {
    local ALIAS="$(nix::shim::my_alias)"
    local GITHUB_ALIAS="$(nix::shim::my_github_alias)"

    nix::log::echo "Welcome to the NIX shim! Please identify yourself."

    if [[ ! "${ALIAS}" ]]; then
        nix::log::prompt 'Microsoft alias (e.g. "chrkin") > '
        ALIAS="${REPLY}"
    fi

    if [[ ! "${GITHUB_ALIAS}" ]]; then
        nix::log::prompt 'Github alias (e.g. "kingces95") > '
        GITHUB_ALIAS="${REPLY}"
    fi

    nix::fs::insert "${NIX_GITHUB_USER_RECORDS}" "${GITHUB_ALIAS} ${ALIAS}"

    nix::log::prompt 'Display name (e.g "Chris King") > '
    local DISPLAY_NAME="${REPLY}"

    nix::log::prompt 'Time zone offset (e.g "-8") > '
    local TZ_OFFSET="${REPLY}"

    local IP_ALLOCATION=$(nix::shim::ip_allocate)
    local ENV_ID=0
    local ENVIRONMENTS=(
        DOGFOOD_INT
        SELFHOST
        INT
        PPE
    )
    local DEFAULT_PROFILE=administrator
    local DEFAULT_ENVIRONMENT=PPE

    # allocate ip
    nix::fs::insert \
        "${NIX_IP_ALLOCATION_RECORDS}" \
        "${ALIAS}" \
        "${IP_ALLOCATION}"

    # allocate personal profile.sh
    local PROFILE="${NIX_PROFILE/$USER/$ALIAS}"
    mkdir -p "$(dirname "${PROFILE}")"

    nix::log::echo "nix: shim: saving profile: ${PROFILE}"
    cat <<- EOF > "${PROFILE}"
		readonly NIX_MY_DISPLAY_NAME="${DISPLAY_NAME}"
		readonly NIX_MY_TZ_OFFSET=${TZ_OFFSET}h
		readonly NIX_MY_IP_ALLOCATION="${IP_ALLOCATION}"
		readonly NIX_MY_ENV_ID=0
		readonly NIX_MY_ENVIRONMENTS=(
		    DOGFOOD_INT
		    SELFHOST
		    INT
		    PPE
		)
		readonly NIX_MY_DEFAULT_PROFILE=${DEFAULT_PROFILE}
		readonly NIX_MY_DEFAULT_ENVIRONMENT=${DEFAULT_ENVIRONMENT}
		source "\${NIX_DIR_NIX_USR}/alias.sh"
		EOF

    nix::shim::profile::push "${DISPLAY_NAME}" "${ALIAS}"
}

nix::shim::profile::push() {
    local DISPLAY_NAME="$1"
    shift

    local ALIAS="$1"
    shift

    nix::git::pull >/dev/null 2>/dev/null

    # assume first touch is from a codespace
    # if ! nix::loader::codespace::test; then
    #   codespaces already configures this 
    #   git config --global user.name "${DISPLAY_NAME}"
    #   git config --global user.email "${ALIAS}@microsoft.com"
    # fi

    local BRANCH="${ALIAS}-onboarding"
    local MESSAGE="Onboarding ${DISPLAY_NAME}"
    local PROFILE="${NIX_PROFILE/$USER/$ALIAS}"

    local FILES=(
        "${PROFILE}"
        "${NIX_GITHUB_USER_RECORDS}"
        "${NIX_IP_ALLOCATION_RECORDS}"
    )

    (
        nix::log::subproc::begin 'nix: github: merging profile'
        
        cd "${NIX_REPO_DIR}"
        nix::git::branch "${BRANCH}"
        nix::git::commit "${MESSAGE}" < \
            <(nix::bash::args "${FILES[@]}")
        nix::git::push
        nix::github::pr::create
        nix::github::pr::merge
        nix::git::checkout 'main'
        nix::git::branch::delete "${BRANCH}"
        nix::git::pull
    )

    nix::log::prompt 'Hit enter to continue.' \
        'Login with your microsoft credentials whenever prompted with a device code.'
}
