CLI_IMPORT=(
    "cli set test"
)

cli::set::intersect::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Intersect two sets.

Description
    Argument \$1 is the name of the first set.
    Argument \$2 is the name of the second set.
    The resulting intersection is returned in map REPLY_MAP.
EOF
}

cli::set::intersect::main() {
    local -A SET0=()
    for i in $1; do
        SET0["$i"]=
    done

    local -A SET1=()
    for i in $2; do
        SET1["$i"]=
    done

    cli::set::intersect SET0 SET1

    printf '%s\n' "${!REPLY_MAP[@]}" | sort
}

cli::set::intersect() {
    declare -gA REPLY_MAP=()

    local SET0_NAME=$1
    local SET1_NAME=$2

    local -n SET0_REF=${SET0_NAME?'Missing set.'}
    local -n SET1_REF=${SET1_NAME?'Missing set.'}

    local ELEMENT
    for ELEMENT in "${!SET0_REF[@]}"; do
        if cli::set::test ${SET1_NAME} "${ELEMENT}"; then
            REPLY_MAP["${ELEMENT}"]=
        fi
    done
}

cli::set::intersect::self_test() {
    diff <(${CLI_COMMAND[@]} -- 'a b c' 'a b') - <<< $'a\nb'
    diff <(${CLI_COMMAND[@]} -- 'a b c' 'b c d') - <<< $'b\nc'
    diff <(${CLI_COMMAND[@]} -- 'a b c' 'd e f') - <<< $''
    diff <(${CLI_COMMAND[@]} -- '' '') - <<< $''
}
