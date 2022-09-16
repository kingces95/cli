nix::bash::map::test() {
    local -n SET_REF=${1:?'Missing set'}
    shift 

    local KEY="$*"

    [[ "${KEY}" ]] && [[ "${SET_REF[${KEY}]+hit}" == 'hit' ]]
}

nix::bash::enum::declare() {
    local ENUM_NAME="$1"
    shift

    local ORDER_NAME="$1"
    shift

    declare -gA "${ENUM_NAME}=()"
    local -n ENUM_REF="${ENUM_NAME}"

    local -n ORDER_REF="${ORDER_NAME}"
    local COUNT="${#ORDER_REF[@]}"

    local -i INDEX
    for (( INDEX=0; INDEX<COUNT; INDEX++ )); do
        local NAME="${ORDER_REF[${INDEX}]}"
        ENUM_REF["${NAME}"]="${INDEX}"
    done

    readonly "${ENUM_NAME}"
}

nix::bash::map::write() {
    local -n MAP_REF=$1
    shift

    local JOIN="${1- }"
    shift
    
    local KEY
    for KEY in "${!MAP_REF[@]}"; do 
        echo "${KEY}${JOIN}${MAP_REF["${KEY}"]}"
    done | sort -k1
}

nix::bash::map::read() {
    local -n MAP_REF="$1"
    shift

    local KEY VALUE
    while read -r KEY VALUE; do
        MAP_REF["${KEY}"]="${VALUE}"
    done
}

nix::bash::map::declare() {
    local NAME="$1"
    shift

    declare -gA "${NAME}=()"
    nix::bash::map::read "${NAME}"
    readonly "${NAME}"
}

nix::bash::map::read_list() {
    local -n MAP_REF="$1"
    shift

    local KEY VALUE
    while read -r KEY VALUE; do
        MAP_REF["${KEY}"]+="${VALUE} "
    done
}
