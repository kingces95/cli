alias dmp="nix::bash::dump::declarations"
alias rec="nix::bash::dump::variables"

alias un="nix::bash::unset::variables"
alias file-name="nix::path::file::name"

alias elem="nix::bash::elements"
alias ret="nix::bash::return"

nix::bash::return() {
    return $1
}

nix::bash::is_set() {
    declare -p "$1" >/dev/null 2>&1
}

nix::bash::reverse() {
    mapfile -t < <(
        nix::bash::args "$@" \
            | tac
    )
}

nix::bash::args() {
    if (( $# == 0 )); then
        return
    fi

    printf '%s\n' "$@"
}

nix::bash::dereference() {
    while read; do
        echo "${!REPLY}"
    done
}

nix::bash::args::sorted() {
    nix::bash::args "$@" | sort
}

nix::bash::elements() {
    local -n ARRAY_REF=$1
    nix::bash::args "${ARRAY_REF[@]}"
}

nix::bash::dump::declarations() {
    while read; do
        declare -p ${REPLY}
    done < <(nix::bash::dump "$@")
}

nix::bash::type() {
    local DECLARE TYPE NAME VALUE
    IFS=" =" read DECLARE TYPE NAME VALUE < <(declare -p $1)

    case ${TYPE} in
    *A*) echo 'map' ;;
    *a*) echo 'array' ;;
    *i*) echo 'long' ;;
    *) echo string ;;
    esac
}

nix::bash::dump::functions() {
    declare -F \
        | nix::record::project 3 3 \
        | egrep "${1-.}"
}

nix::bash::variable::print() {
    local NAME="$1"
    shift

    local TYPE=$(nix::bash::type "${NAME}")
    case "${TYPE}" in
    *A*) ;&
    *a*) 
        local -n REF="${NAME}"
        for KEY in "${!REF[@]}"; do
            echo "${NAME}" "${TYPE}" "${KEY}" "${REF[${KEY}]}"
        done
    ;;
    *) echo "${NAME}" "${TYPE}" '-' "${!NAME}" ;;
    esac
}

nix::bash::dump::variables() {
    while read; do
        nix::bash::variable::print "${REPLY}"
    done < <(nix::bash::dump "$@")
}

nix::bash::name::to_bash() {
    local NAME="$*"
    NAME="${NAME^^}"
    NAME="${NAME// /_}"
    NAME="${NAME//-/_}"
    echo "${NAME}"
}

nix::bash::char_count() {
    grep -o "[$1]" <<< "${REPLY}" | wc -l
}

nix::bash::dump() {
    local MATCH="$1"
    MATCH="${MATCH^^}"
    MATCH="${MATCH//-/_}"

    while (( $# > 0 )); do
        for REPLY in $(eval "echo \${!${MATCH}*}"); do
            echo ${REPLY}
        done
        shift
    done | sort
}

nix::bash::join() {
    local DELIMITER="${1?'Missing delimiter'}"
    shift

    local FIRST=true
    while (( $# > 0 )); do
        local VALUE="$1"
        shift 

        if [[ ! "${VALUE}" ]]; then
            continue
        fi

        if ! "${FIRST}"; then
            echo -n "${DELIMITER}"
        fi
        FIRST=false

        echo -n "${VALUE}" 
    done

    if ! $FIRST; then
        echo
    fi
}

nix::bash::function::test() {
    local NAME="$1"
    shift

    declare -f "${NAME}" >/dev/null
}

nix::bash::function::parts() {
    local NAME="$1"
    nix::bash::args ${NAME//::/ }
}

nix::bash::function() {
    local FRAME_OFFSET=${1-0}
    local FRAME_BASE=3
    local FRAME=$(( FRAME_OFFSET + FRAME_BASE ))
    nix::bash::function::parts ${FRAME}
}

nix::bash::caller() {
    nix::bash::function "$@"
}

nix::bash::expand() {
    while read -r; do echo "${REPLY//\\/\\\\}"; done \
        | while read -r; do eval "echo \"${REPLY}\""; done
}

nix::string::repeat() {
    local COUNT="$1"
    shift

    local VALUE="$1"
    shift

    local -i INDEX
    for (( INDEX=0; INDEX < COUNT; INDEX++ )); do
        echo -n "${VALUE}"
    done

    echo
}

nix::string::indent() {
    local DEPTH="$1"
    shift
    
    echo -n "$(nix::string::repeat "${DEPTH}" ' ')"
}

nix::bash::symbol::test() {
    local SYMBOL="$1"
    shift

    declare -p "${SYMBOL}" >/dev/null 2>/dev/null
}

nix::bash::symbol::readonly::test() {
    local -n REF="$1"
    shift

    ( REF=a ) 2>/dev/null >/devnull
    (( $? ))
}

nix::bash::tty::test() {
    bash -c ": >/dev/tty" >/dev/null 2>/dev/null
}

nix::bash::timeout() {
    local TIMEOUT="$1"
    shift

    local TICKS
    for (( TICKS=0; TICKS<"${TIMEOUT}"; TICKS++ )); do
        if "$@"; then
            return;
        fi
          
        sleep 1
    done

    echo "ERROR: Timeout waiting for port '$@'." 1>&2
    return 1
}

