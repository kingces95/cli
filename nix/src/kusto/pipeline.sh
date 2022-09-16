alias kusto-cmd="nix::kusto::pipeline::cmd"

nix::kusto::pipeline::main() (
    local NIX_KUSTO_SPY="$1"
    shift

    exec 3>&1

    local SPY=nix::kusto::spy
    cat \
        | "${SPY}" nix::kusto::pipeline::query::substitute::literal \
        | "${SPY}" nix::kusto::pipeline::query::parse \
        | "${SPY}" nix::kusto::pipeline::query::substitute "$@" \
        | "${SPY}" nix::kusto::pipeline::query::minify \
        | "${SPY}" nix::kusto::pipeline::cmd \
        | "${SPY}" nix::kusto::pipeline::cmd::compile \
        | "${SPY}" nix::kusto::pipeline::execute \
        | "${SPY}" nix::kusto::pipeline::format::focus \
        | "${SPY}" nix::kusto::pipeline::format::tidy \
        | "${SPY}" nix::kusto::pipeline::format::headers \
        | "${SPY}" nix::kusto::pipeline::format::align
)

nix::kusto::pipeline::query::substitute::literal() {
    sed "s/\"HH:mm:ss\"/\"${NIX_KUSTO_TIME_FORMAT-HH:mm:ss}\"/g"
}

nix::kusto::pipeline::query::parse() {
    # source -> records
    while read; do
        local LINE="${REPLY}"

        read OP OP_REPLY <<< "${LINE}"
        case ${OP} in
        'let')
            IFS='=; ' read NAME VALUE <<< "${OP_REPLY}"
            local TYPE=$(nix::kusto::query::infer_type "${VALUE}")
            echo "${TYPE} ${NAME} ${VALUE}"
            ;;

        *)
            echo
            echo "${LINE}"
            cat
            return;
            ;;
        esac
    done
}

nix::kusto::pipeline::query::personalizations() {
    cat
    echo "timespan timeZoneOffset ${NIX_MY_TZ_OFFSET-0h}"
}

nix::kusto::pipeline::query::substitutions() {
    while read TYPE NAME VALUE; do

        # override default substitutions
        if (( $# > 0 )); then
            VALUE="$1"
            shift

            case "${TYPE}" in
            # quote strings
            'string') 
                VALUE="\"${VALUE}\""
                ;;

            # wrap timespan in "ago"
            'datetime')
                local VALUE_TYPE=$(nix::kusto::query::infer_type ${VALUE})
                if [[ "${VALUE_TYPE}" == 'timespan' ]]; then
                    VALUE="ago(${VALUE})"
                fi
                ;;
            esac
        fi

        echo "${NAME} ${VALUE}"
    done
}

nix::kusto::pipeline::query::substitute() {
    local TMP=$(mktemp)

    nix::line::take::chunk \
        | nix::kusto::pipeline::query::personalizations \
        | nix::kusto::pipeline::query::substitutions "$@" \
        | nix::record::override \
        | tee "${TMP}" \
        | nix::record::printf 2 '# %s %s' \
        | nix::record::align 3

    read -r SED_OP < <(
        cat ${TMP} \
            | nix::sed::op::replace::many
    )

    sed "${SED_OP}"

    rm ${TMP}
}

nix::kusto::pipeline::query::minify() {
    mapfile -t < <(grep -v "#")
    echo "${MAPFILE[*]}"
}

nix::kusto::pipeline::cmd() {
    mapfile -t QUERY

    nix::dotnet::cmd
    nix::cmd::argument "${NIX_KUSTO_DLL}"
    nix::cmd::argument "$(nix::kusto::connection_string)"
    nix::cmd::option-colon 'e' "${QUERY[*]}"
}

nix::kusto::pipeline::cmd::compile() {
    nix::cmd::compile
}

nix::kusto::pipeline::execute() {
    nix::line::execute
}

nix::kusto::pipeline::format::focus() {
    # first ------
    while read -r; do
        if [[ "${REPLY}" =~ ^[[:blank:]]+- ]]; then
            break
        fi
    done

    # second ------
    while read -r; do
        if [[ "${REPLY}" =~ ^[[:blank:]]*- ]]; then
            break
        fi
        echo "${REPLY}"
    done

    # last ------
    while read -r; do
        if [[ "${REPLY}" =~ ^[[:blank:]]*- ]]; then
            break
        fi
        echo "${REPLY}"
    done
}

nix::kusto::pipeline::format::tidy() {
    while read -r; do 
        REPLY=${REPLY//'##dynamic(null)'/'-'}

        # new lines appearing in messages create blank 
        # records except for the next line of the message.
        if [[ "${REPLY}" =~ ^[[:blank:]]*[|] ]]; then
            continue
        fi
        echo "${REPLY}"
    done
}

nix::kusto::pipeline::format::headers() {
    local SKIP=0
    if [[ "${NIX_KUSTO_PIPELINE_SKIP}" ]]; then
        SKIP=1
    fi

    nix::line::skip "${SKIP}"
}

nix::kusto::pipeline::format::align() {
    if ! read -r; then
        return
    fi

    local BARS=$(nix::bash::char_count '|')

    { echo ${REPLY}; cat; } \
        | IFS='| ' nix::record::align $(( ${BARS} + 1 ))
}
