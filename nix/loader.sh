nix::loader::main() {

    # on exit, nuke the .azure directory for this shell
    trap nix::loader::on_exit EXIT

    # load variables
    . "$(dirname ${NIX_DIR_NIX_SRC:-${BASH_SOURCE}})/env.sh"

    # load functions; source *.sh files
    while read; do source "${REPLY}"; done \
        < <(find "${NIX_DIR_NIX_SRC}" -type f -name "*.sh")

    # load computed variables
    nix::loader::computed

    # load stubs
    nix::loader::stubs

    # load profile
    . "${NIX_PROFILE}"

    # load computed profile variables
    nix::loader::profile::computed

    # eagerly install tools needed to lazily install other tools
    local TOOL
    for TOOL in "${NIX_TOOL_EAGERLY_INSTALL[@]}"; do
        nix::tool::install "${TOOL}"
    done

    export PS1="\$(nix::loader::prompt)"

    cd "${NIX_REPO_DIR}"

    if [[ ! "${NIX_FID_NAME}" ]] && \
        [[ "${NIX_MY_DEFAULT_PROFILE}" ]] && \
        [[ "${NIX_MY_DEFAULT_ENVIRONMENT}" ]]; then

        nix::env::tenant::switch \
            "${NIX_MY_DEFAULT_ENVIRONMENT}" \
            "${NIX_MY_DEFAULT_PROFILE}"
    fi
}

nix::loader::prebuild() {
    nix::tool::install::all
}

nix::loader::profile::computed() {
    readonly NIX_MY_RESOURCE_GROUP="${NIX_USER}-rg"
    readonly NIX_MY_VNET="${NIX_USER}-vnet"
    readonly NIX_MY_SUBNET='default'
    readonly NIX_MY_LOCATION=westus3
}

nix::loader::prompt() {
    local RESULT=$?

    local FIDALGO_CONTEXT=()
    FIDALGO_CONTEXT+=( "${NIX_USER}" "${NIX_MY_ENV_ID}" )

    if [[ "${NIX_FID_NAME}" ]]; then
        FIDALGO_CONTEXT+=( "${NIX_FID_NAME}" )
        if [[ ! "${NIX_ENV_PERSONA}" == "${NIX_PERSONA_ADMINISTRATOR}" ]]; then
            FIDALGO_CONTEXT+=( "${NIX_ENV_PERSONA}" )
        fi
    fi

    local PROMPT=( "[${FIDALGO_CONTEXT[*]}]" )

    local DIR="$(pwd)"
    DIR="${DIR/${NIX_REPO_DIR}/...}"
    PROMPT+=( "${DIR}/" )

    if (( RESULT )); then
        # vscode console does not like colored prompts
        # PROMPT+=( "$(nix::color::red ${RESULT})" )
        PROMPT+=( "${RESULT}" )
    fi

    PROMPT+=( '$' )

    echo -e "${PROMPT[*]} "
}

nix::loader::computed() {
    mapfile -t NIX_AZURE_RESOURCE_ACTIVATION_ORDER < <(
        nix::bash::map::poset::total_order NIX_AZURE_RESOURCE_ACTIVATION_POSET
    )
    readonly NIX_AZURE_RESOURCE_ACTIVATION_ORDER

    nix::bash::enum::declare \
        NIX_AZURE_RESOURCE_ACTIVATION_ENUM \
        NIX_AZURE_RESOURCE_ACTIVATION_ORDER

    nix::bash::enum::declare \
        NIX_TEST_OPTION_ENUM \
        NIX_TEST_OPTION_ORDER

    nix::bash::enum::declare \
        NIX_TEST_OP_ENUM \
        NIX_TEST_OP_ORDER

    readonly NIX_HOST_IP="$(nix::host::ip)"

    # github alias -> microsoft alias
    nix::bash::map::declare "NIX_GITHUB_USER" < "${NIX_GITHUB_USER_RECORDS}"

    # microsoft alias -> ip allocations
    nix::bash::map::declare "NIX_IP_ALLOCATION" < "${NIX_IP_ALLOCATION_RECORDS}"
}

nix::loader::on_exit() {
    local EXIT_CODE=$?
    
    if (( EXIT_CODE == NIX_EXIT_RELOAD )); then
        return
    fi
            
    nix::azure::tenant::profile::clear
}

nix::loader::ps4() {
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
}

nix::loader::stubs() {
    jq() { nix::tool::stub "$@"; }
    nuget() { nix::tool::stub "$@"; }
    gpg() { nix::tool::stub "$@"; }
    dotnet() { nix::tool::stub "$@"; }
    curl() { nix::tool::stub "$@"; }
    netstat() { nix::tool::stub "$@"; }
    az() { nix::tool::stub "$@"; }
    man() { nix::tool::stub "$@"; }
    gh() { nix::tool::stub "$@"; }
    go() { nix::tool::stub "$@"; }
    azbridge() { nix::tool::stub "$@"; }
    nc() { nix::tool::stub "$@"; }
    nano() { nix::tool::stub "$@"; }
    colordiff() { nix::tool::stub "$@"; }
    killall() { nix::tool::stub "$@"; }
    add-apt-repository() { nix::tool::stub "$@"; }
    # git() { nix::tool::git::stub "$@"; }
}

nix::loader::lastpipe() {
    # run last pipe in same process that launched the pipeline
    shopt -s lastpipe

    # disable job control so lastpipe works in interactive mode
    set +m
}

nix::loader::generate() {
    nix::kusto::csl::harvest NIX_REPO_DIR_KUSTO \
        > "${NIX_DIR}/src/fidalgo/etc/dri.g.sh"

    nix::azure::cmd::emit::harvest \
        > "${NIX_DIR}/src/az/az.g.sh"
}

nix::loader::exit() {
    local EXIT_CODE="$1"

    exit "${EXIT_CODE}" >/dev/null 2>&1

    # if jobs are running, calling exit twice kills them and exits
    exit "${EXIT_CODE}" >/dev/null 2>&1
}

nix::loader::break() {
    nix::loader::exit "${NIX_EXIT_REMAIN}"
}

nix::loader::recreate() {
    nix::loader::exit "${NIX_EXIT_CHROOT_REINITIALIZE}"
}

nix::loader::unload() {
    nix::loader::exit "${NIX_EXIT_CHROOT_REMOVE}"
}

nix::loader::reload() {
    nix::loader::exit "${NIX_EXIT_RELOAD}"
}

nix::loader::relogin() {
    nix::loader::rc::base > "${NIX_BASH_PROFILE}"
    nix::loader::rc::relogin >> "${NIX_BASH_PROFILE}"
    nix::loader::rc::cd >> "${NIX_BASH_PROFILE}"
    nix::loader::reload
}

nix::loader::regenerate() {
    nix::loader::rc::base > "${NIX_BASH_PROFILE}"
    nix::loader::rc::cd >> "${NIX_BASH_PROFILE}"
    nix::loader::rc::regenerate >> "${NIX_BASH_PROFILE}"
    nix::loader::reload
}

nix::loader::rc::base() {
	echo '. "${HOME}/.bash_login"'
}

nix::loader::rc::cd() {
    echo "cd ${PWD}"
}

nix::loader::rc::regenerate() {
    echo "NIX_FID_NAME=${NIX_FID_NAME}"
    echo "NIX_ENV_PERSONA=${NIX_ENV_PERSONA}"
    echo "nix::loader::generate"
    echo "nix::loader::rc::relogin"
}

nix::loader::rc::relogin() {
    if [[ ! "${NIX_FID_NAME}" ]]; then
        return
    fi

    echo "nix::env::tenant::switch" \
        "${NIX_FID_NAME}" \
        "${NIX_ENV_PERSONA}"
}

nix::loader::main
