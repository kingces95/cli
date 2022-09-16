alias cat-http="nix::http"
alias http-curl="nix::http::pipeline"
alias cat-curl="nix::http | nix::http::pipeline"

nix::http::enum() {
    nix::bash::elements NIX_HIT_ORDER \
        | nix::record::number
}

nix::http::pipeline() {
    local NIX_CURL_PORT
    local NIX_CURL_HOST
    local NIX_CURL_SCHEME

    local -a NIX_CURL_SEGMENTS=()
    local -A NIX_CURL_QUERY=()
    while nix::record::mapfile 3; do
        local TYPE KEY VALUE
        TYPE="${MAPFILE}"
        KEY="${MAPFILE[1]}"
        VALUE="${MAPFILE[2]}"

        case "${TYPE}" in
        'scheme') NIX_CURL_SCHEME="${KEY}" ;;
        'host') NIX_CURL_HOST="${KEY}" ;;
        'port') NIX_CURL_PORT="${KEY}" ;;
        'segment') NIX_CURL_SEGMENTS+=( "${KEY}" ) ;;
        'query') NIX_CURL_QUERY["${KEY}"]="${VALUE}" ;;
        'method') 
            case "${KEY}" in
                'get') nix::http::curl::get ;;
                'put') nix::http::curl::put ;;
                'list') nix::http::curl::get ;;
            esac
        ;;
        esac
    done
}

nix::http() {
    local ROUTE="$1"
    shift
    
    local METHOD=get 
    local JSON TYPE LIST

    if [[ "${ROUTE}" =~ [.]json$ ]]; then
        JSON="${ROUTE}"
       
        METHOD=put
        ROUTE="$(nix::path::dir ${ROUTE})"
    fi

    if [[ "${ROUTE}" =~ /$ ]]; then
        ROUTE="${ROUTE%/}"
        LIST=false
    fi

    nix::http::args "$@"

    nix::http::route "${ROUTE}"

    echo 'method' "${METHOD}"
    if [[ "${JSON}" ]]; then
        read -r SED_OP < <(
            nix::bash::map::write REPLY_NIX_HIT_ARGS \
                | sed 's/^/--/g' \
                | nix::sed::op::replace::many
        )

        cat "${JSON}" | sed "${SED_OP}"
    fi
}

nix::http::route() {
    local ROUTE="$1"
    shift

    local DOT="${ROUTE}/.route"
    if [[ ! -f "${DOT}" ]]; then
        return
    fi

    if [[ ! "${ROUTE}" == '.' ]]; then
        nix::http::route "$(nix::path::dir "${ROUTE}")"
        echo 'segment' "$(nix::path::file "${ROUTE}")"
    fi

    local TYPE KEY VALUE
    cat "${DOT}" | while read TYPE KEY VALUE; do
        case "${TYPE}" in
        'query') echo "${TYPE}" "${KEY}" "$(nix::http::route::resolve "${KEY}" "${VALUE}")" ;;
        'segment') echo "${TYPE}" "$(nix::http::route::resolve "${KEY}" "${VALUE}")" ;;
        *) echo "${TYPE}" "${KEY}" "${VALUE}" ;;
        esac
    done
}

nix::http::route::resolve() {
    local KEY="$1"
    shift

    local VALUE="$1"
    shift

    local VARIABLE="NIX_${KEY^^}"
    VARIABLE="${VARIABLE//-/_}"
    local -n VARIABLE_REF="${VARIABLE}"

    if nix::bash::map::test REPLY_NIX_HIT_ARGS "${KEY}"; then
        echo "${REPLY_NIX_HIT_ARGS[${KEY}]}"
    elif [[ "${VARIABLE_REF}" ]]; then
        echo "${VARIABLE_REF}"
    elif [[ "${VALUE}" ]]; then
        echo "${VALUE}"
    else
        echo "--${KEY}"
    fi
    
}

nix::sed::op::replace::many() {
    sed 's/\//\\\\\//g' \
        | nix::record::printf 2 's/%s/%s/g' \
        | nix::line::join '; ' 
}

nix::http::args() {
    declare -gA REPLY_NIX_HIT_ARGS=()

    while (( $# > 0 )); do
        local PAIR="$1"
        shift

        PAIR="${PAIR:2}" # strip --
        local KEY="${PAIR%%=*}"
        local VALUE="${PAIR##*=}"

        REPLY_NIX_HIT_ARGS[${KEY}]="${VALUE}"
    done
}
