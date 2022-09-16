nix::row::filter::match() {
    nix::row::filter 'match' "$@"
}

nix::row::filter::regex() {
    nix::row::filter 'regex' "$@"
}

nix::row::filter::glob() {
    nix::row::filter 'glob' "$@"
}

nix::row::filter() {
    local KIND="$1"
    shift

    local SEARCH_TERM="$1"
    shift

    local COLUMN="${1-1}"
    shift

    local INDEX="$(( COLUMN - 1 ))"
    local VALUE="${MAPFILE[INDEX]}"

    if ! case "${KIND}" in
            'match') [[ "${VALUE}" == "${SEARCH_TERM}" ]] ;;
            'glob') [[ "${VALUE}" == ${SEARCH_TERM} ]] ;;
            'regex') [[ "${VALUE}" =~ ${SEARCH_TERM} ]] ;;
        esac
    then 
        return
    fi

    echo "${MAPFILE[@]}"
}

nix::row::project() {
    local -a ROW=()
    local COLUMN
    for COLUMN in "$@"; do
        local INDEX=$(( COLUMN - 1 ))
        local VALUE="${MAPFILE[${INDEX}]}"
        ROW+=( "${VALUE}" )
    done
    echo "${ROW[@]}"
}

nix::row::shift() {
    local COUNT="${1-1}"
    shift

    set -- "${MAPFILE[@]}"
    shift "${COUNT}"

    echo "$@"
}

nix::row::trim() {
    echo "${MAPFILE[@]}"
}

nix::row::swap() {
    local COLUMN_A="$1"
    shift

    local COLUMN_B="$1"
    shift

    local INDEX_A=$(( COLUMN_A - 1))
    local INDEX_B=$(( COLUMN_B - 1))

    local TEMP="${MAPFILE[INDEX_A]}"
    MAPFILE[INDEX_A]="${MAPFILE[INDEX_B]}"
    MAPFILE[INDEX_B]="${TEMP}"

    echo "${MAPFILE[@]}"
}

nix::row::promote() {
    local COLUMN="$1"
    shift

    local INDEX=$(( COLUMN - 1 ))

    local RESULT=(
        "${MAPFILE[INDEX]}"
        "${MAPFILE[@]}"
    )
    unset RESULT[COLUMN]

    echo "${RESULT[@]}"
}

nix::row::replace() {
    local MAPS=( "$@" )

    local -i INDEX
    for (( INDEX=0; INDEX<${#MAPS[@]}; INDEX++ )); do
        if [[ ! "${MAPS[${INDEX}]}" ]]; then
            continue
        fi

        local VALUE="${MAPFILE["${INDEX}"]}"
        
        local -n MAP_REF="${MAPS[${INDEX}]}"
        MAPFILE["${INDEX}"]="${MAP_REF[${VALUE}]-?}"
    done
    echo "${MAPFILE[*]}"
}

nix::row::copy() {
    local COLUMN="${1-1}"
    shift

    local INDEX=$(( COLUMN - 1 ))

    echo "${MAPFILE[@]:0:${COLUMN}} ${MAPFILE[@]:${INDEX}}"
}

nix::row::delete() {
    local COLUMN="${1-1}"
    shift

    local INDEX=$(( COLUMN - 1 ))
    local COPY=( "${MAPFILE[@]}" )
    unset COPY[${INDEX}]

    echo "${COPY[@]}"
}
