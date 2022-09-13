#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli set test"
)

cli::bash::map::copy::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copy select keys from source to target map.

Description
    Argument \$1 is the name of the source map.
    Argument \$2 is the name of the target map.
    Arguments \$3 - \$n are the names of the keys to copy.

    If a key does not exist in the source map then the key is skipped.
EOF
}

cli::bash::map::copy() {
    local SOURCE_MAP=${1-}
    [[ "${SOURCE_MAP}" ]] || cli::assert 'Missing source map.'
    shift

    local TARGET_MAP=${1-}
    [[ "${TARGET_MAP}" ]] || cli::assert 'Missing target map.'
    shift

    local -n SOURCE_REF=${SOURCE_MAP}
    local -n TARGET_REF=${TARGET_MAP}

    while (( $# > 0 )); do
        local KEY=$1
        shift

        if ! cli::set::test ${SOURCE_MAP} ${KEY}; then
            continue
        fi

        TARGET_REF[${KEY}]="${SOURCE_REF[${KEY}]}"
    done
}

cli::bash::map::copy::self_test() {
    local -A SOURCE=( [a]=0 [b]=1 [c]=2 )
    local -A TARGET=( [a]=x )
    ${CLI_COMMAND[@]} --- SOURCE TARGET a b d

    diff <(declare -p TARGET) - <<< $'declare -A TARGET=([b]="1" [a]="0" )' || cli::assert
}
