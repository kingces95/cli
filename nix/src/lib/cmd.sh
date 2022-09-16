alias fd-cmd="nix::cmd::compile"
alias fd-cmd-exe="nix::cmd::run"
alias fd-cmd-show="nix::cmd::compile | nix::line::join"
alias fd-cmd-emit="nix::cmd::compile | nix::cmd::pretty"

nix::cmd::option::decorate() {
    local NAME="$1"
    local PREFIX='-'

    if ! (( ${#NAME} == 1 )); then
        PREFIX='--'
    fi

    printf '%s\n' "${PREFIX}${NAME}"
}

nix::cmd::flag() {
    echo "flag $1"
}

nix::cmd::option() {
    if [[ ! "$2" ]]; then
        return
    fi
    echo "option $1 $2"
}

nix::cmd::option::list() {
    echo "option-list $1"
}

nix::cmd::option::list::item() {
    if [[ ! "$2" ]]; then
        return
    fi
    echo "option-list-item $1 $2"
}

nix::cmd::option-colon() {
    echo "option-colon $1 $2"
}

nix::cmd::name() {
    echo "command name $1"
}

nix::cmd::path() {
    echo "command path $1"
}

nix::cmd::argument() {
    echo "command argument $1"
}

nix::cmd::compile() {
    local COMMAND="$1"
    local PTH=
    local ARGS=()
    local -A FLAGS=()

    local OP KEY VALUE
    while read OP KEY VALUE; do
        case "${OP}" in
        'command')
            case "${KEY}" in
            'name')
                COMMAND="${VALUE}"
            ;;
            'path')
                PTH="${VALUE}"
            ;;
            'argument')
                ARGS+=( "${VALUE}" )
            ;;
            esac
            ;;
        'flag')
            if ! nix::bash::map::test FLAGS "${KEY}"; then
                FLAGS[${KEY}]=true

                local DECORATED_KEY=$(nix::cmd::option::decorate ${KEY})
                ARGS+=( "${DECORATED_KEY}" )
            fi
            ;;
        'option'*)
            local DECORATED_KEY=$(nix::cmd::option::decorate ${KEY})
            
            case "${OP}" in
            'option')
                ARGS+=( "${DECORATED_KEY}" )
                ARGS+=( "${VALUE}" )
                ;;
            'option-list')
                ARGS+=( "${DECORATED_KEY}" )
                ;;
            'option-list-item')
                ARGS+=( "${KEY}=${VALUE}" )
                ;;
            *)
                local JOIN
                case "${OP}" in
                'option-equals') JOIN='=' ;;
                'option-colon') JOIN=':' ;;
                *) 
                    echo "Unknown OP: ${OP}" >&2
                    return 1
                esac
                ARGS+=( "${DECORATED_KEY}${JOIN}${VALUE}" )
                ;;
            esac
            ;;
        *)
            echo "Unknown OP=${OP}, KEY=${KEY}, VALUE=${VALUE}" >&2
            return 1
        esac
    done

    local FULL_PATH="${COMMAND}"
    if [[ "${PTH}" ]]; then
        FULL_PATH="${PTH}/${COMMAND}"
    fi

    if [[ "${FULL_PATH}" ]]; then
        echo "${FULL_PATH}"
    fi

    nix::bash::args "${ARGS[@]}"
}

nix::cmd::run() {
    nix::cmd::compile \
        | nix::line::execute
}

nix::cmd::pretty() {
    { # ugly
        local JOIN=
        while true; do
            if ! read -r; then
                echo
                return;
            fi

            if [[ "${REPLY}" =~ ^- ]]; then
                break;
            fi
            printf '%s%s' "${JOIN}" "${REPLY}"
            JOIN=' '
        done
        echo

        while true; do
            printf '%s' "${REPLY}"

            while true; do
                if ! read -r; then
                    echo
                    return;
                fi

                if [[ "${REPLY}" =~ ^- ]]; then
                    break;
                fi
            
                printf ' %s' "${REPLY}"
            done

            echo
        done | nix::bash::emit::indent
    } | nix::bash::emit::continue_line
}

nix::cmd::emit::command() {
    local -A ENUM=(
        [path]=0
        [name]=1
    )
    
    egrep '^command (name|path)' \
        | nix::record::shift 2 \
        | nix::record::replace ENUM \
        | sort -s -k1,1n \
        | nix::line::join '/' \
        | nix::record::shift 2
}

nix::cmd::emit::arguments::positional() {
    egrep '^command argument' \
        | nix::record::shift 2 \
        | nix::record::shift 2 \
        | nix::line::join
}

nix::cmd::emit::arguments::named() {
    while read -r OP KEY VALUE; do
        local DECORATED_KEY=$(nix::cmd::option::decorate ${KEY})

        local JOIN
        case "${OP}" in
            'flag') JOIN= ;;
            'option-list') JOIN= ;;
            'option') JOIN=' ' ;;
            'option-equals') JOIN='=' ;;
            'option-colon') JOIN=':' ;;
            *) 
                echo "Unknown OP: ${OP}" >&2
                return 1
        esac

        echo "${DECORATED_KEY}${JOIN}${VALUE}"

        while read -r ITEM KEY VALUE; do
            echo "${KEY}=${VALUE}"
        done < <(nix::line::take::chunk) \
            | nix::bash::emit::indent

    done < <(
        egrep '^(option|flag)' \
            | sed 's/^option-list-item/item/' \
            | nix::line::chunk '^(option|flag)'
    )
}

nix::cmd::emit() {
    local TMP=$(mktemp)
    cat > "${TMP}"

    {
        printf '%s %s\n' \
            "$(nix::cmd::emit::command < "${TMP}")" \
            "$(nix::cmd::emit::arguments::positional < "${TMP}")"
        nix::cmd::emit::arguments::named < "${TMP}" \
            | nix::bash::emit::indent
    } | nix::bash::emit::continue_line

    rm "${TMP}"
}

