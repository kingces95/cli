alias afs="nix::azure::fs::dump | a2f"
alias afs-unset="nix::azure::fs::unset"
alias afs-set="nix::azure::fs::set"
alias afs-query="nix::azure::fs::query"
alias afs-emit="nix::azure::fs::emit"
alias afs-context-cat="nix::azure::fs::context::cat"
alias afs-context-find="nix::azure::fs::context::find"

# cd /az/dogfood/default
# afs-context-find > lists files
# afs-context-cat > emits chunks with headers (filename, dirname) followed by values; stream of file context
# afs-emit > emit bash code

nix::azure::fs::context::find() {
    local DIR="$1"
    shift

    nix::fs::context::find az "${DIR}"
}

nix::azure::fs::context::cat() {
    local DIR="$1"
    shift

    nix::azure::fs::context::find "${DIR}" \
        | nix::fs::context::cat
}

nix::azure::fs::dump() {
    nix::bash::dump::variables 'NIX_AZ_'
}

nix::azure::fs::unset() {
    nix::context::clear
}

nix::azure::fs::initialize() {
    local NIX_AZ_UPN="${NIX_AZ_USER_NAME}@${NIX_AZ_USER_DOMAIN}"

    # set AZURE_CONFIG_DIR
    nix::azure::tenant::profile::set "${NIX_AZ_UPN}" "${NIX_AZ_TENANT}"

    # initialize .azure/upn/tenant directory
    time nix::azure::tenant::profile::initialize \
        "${NIX_AZ_UPN}" \
        "${NIX_AZ_TENANT}" \
        "${NIX_AZ_TENANT_CLOUD}" \
        "${NIX_AZ_SUBSCRIPTION}" \
        "${NIX_AZ_SUBSCRIPTION_NAME}"

    # share tokens between .azure/upn/tenant directories
    nix::azure::tenant::profile::share_tokens
}

nix::azure::fs::login() {
    local NIX_AZ_UPN="${NIX_AZ_USER_NAME}@${NIX_AZ_USER_DOMAIN}"

    # register cloud
    if ! nix::azure::cloud::is_registered "${NIX_AZ_TENANT_CLOUD}"; then
        nix::azure::cloud::register
    fi

    # set cloud
    time nix::az::cloud::set "${NIX_AZ_TENANT_CLOUD}"

    # login
    if [[ "${NIX_AZ_UPN}" =~ @microsoft[.]com$ ]]; then
        nix::az::login::with_device_code "${TENANT}" >/dev/null
    else
        local SECRET="$(nix::secret::azure::password::get)"

        nix::az::login::with_secret \
            "${NIX_AZ_UPN}" \
            "${SECRET}" \
            "${NIX_AZ_TENANT}" \
            >/dev/null

    fi || return

    # nix::az::account::set "${SUBSCRIPTION}"
}

nix::azure::fs::set() {
    local DIR="$1"
    shift

    nix::azure::fs::unset
    source <(nix::azure::fs::emit "${DIR}")
}

nix::azure::fs::query() (
    local DIR="$1"
    shift

    nix::azure::fs::set "${DIR}"
    nix::bash::dereference
)

#
# nix::azure
#

nix::azure::login::trap() {
    local LOG="$(mktemp)"
    local LOGIN_ERROR="az login"

    while true; do
        $(which az) "$@" 2> "${LOG}"

        if read < "${LOG}" && \
            [[ "${REPLY}" =~ "${LOGIN_ERROR}" ]]; then

            nix::azure::fs::login
            continue
        fi
          
        cat "${LOG}" >&2
        break
    done
}

#
# nix::azure::fs::emit
#

nix::azure::fs::emit::context() {
    cat \
    | while read -r TYPE KEY VALUE; do
        if [[ "${KEY}" == 'id' ]]; then
            KEY=
        fi

        local NAME="$(nix::bash::name::to_bash ${TYPE} ${KEY})"
        echo nix::context::add "NIX_AZ_${NAME} \"${VALUE}\""
    done
}

nix::azure::fs::emit::name() {
    echo nix::context::add NIX_AZ_NAME \""$@"\"

    nix::azure::fs::emit::context
}

nix::azure::fs::emit::child_of() {
    local NAME="$(nix::bash::name::to_bash $1)"
    shift

    echo nix::context::add "NIX_AZ_${NAME}_NAME \"\${NIX_AZ_NAME}\""

    nix::azure::fs::emit::name "$@"
}

nix::azure::fs::emit() {
    local DIR="$1"
    shift

    nix::azure::fs::context::cat "${DIR}" \
        | nix::fs::context::dispatch \
            'nix::azure::fs::emit' \
            'nix::azure::fs::emit::context'
}

nix::azure::fs::emit::user() {
    nix::azure::fs::emit::name "${NIX_USER}"
    nix::azure::fs::emit::context
}
nix::azure::fs::emit::tenant() {
    nix::azure::fs::emit::child_of 'user' "$@"
    echo '#' "nix::azure::fs::login"
}
nix::azure::fs::emit::subscription() {
    nix::azure::fs::emit::child_of 'tenant' "$@"
}
nix::azure::fs::emit::group() {
    nix::azure::fs::emit::child_of 'subscription' "$@"
}
nix::azure::fs::emit::vnet() {
    nix::azure::fs::emit::child_of 'resource-group' "$@"
}
nix::azure::fs::emit::subnet() {
    nix::azure::fs::emit::child_of 'vnet' "$@"
}

#
# nix::fs::context
#

nix::fs::context::dispatch() {
    local FUNCTION_PREFIX="$1"
    shift

    local FUNCTION_DEFAULT="$1"
    shift

    local TYPE NAME
    while read -r TYPE NAME; do
        echo "# ${TYPE} ${NAME}"
        nix::line::take::chunk \
            | {
                local FUNC="${FUNCTION_PREFIX}::${TYPE}"

                # dispatch
                if nix::bash::function::test "${FUNC}"; then
                    "${FUNC}" "${NAME}"
                else
                    "${FUNCTION_DEFAULT}"
                fi
            }
    done
}

nix::fs::context::cat() {
    # input: stream of file name
    # emits chunks with headers (filename, dirname) followed by values

    local -i CHUNK=0
    while read; do
        local PTH="${REPLY}"
        local FILE_NAME="$(nix::path::file::name ${PTH})"
        local DIR_NAME="$(nix::path::dir::name ${PTH})"

        if (( CHUNK > 0 )); then
            echo
        fi

        echo "${FILE_NAME}" "${DIR_NAME}"
        cat "${PTH}" | sed "s/^/${FILE_NAME} /g"
        CHUNK+=1
    done
}

nix::fs::context::find() (
    # for dir and ancestors, list all files with given suffex

    shopt -s nullglob

    local SUFFIX="$1"
    shift

    local DIR="${1:-$PWD}"
    shift

    if [[ "${DIR}" == '/' ]]; then
        return
    fi

    local FILE=( "${DIR}"/*.${SUFFIX} )

    local PARENT=$(dirname "${DIR}")
    nix::fs::context::find "${SUFFIX}" "${PARENT}"

    if [[ "${FILE}" ]]; then
        echo "${FILE}"
    fi
)
