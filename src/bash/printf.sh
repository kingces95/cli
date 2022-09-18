#! inline

cli::bash::printf::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Like printf except print nothing if no arguments.
EOF
}

cli::bash::printf() {
    local FORMAT=${1-}
    [[ $"{FORMAT}" ]] || cli::assert 'Missing format.'
    shift

    if (( $# == 0 )); then
        return
    fi

    printf "${FORMAT}" "$@"
}

cli::bash::printf::self_test() {
    diff <(${CLI_COMMAND[@]} -- '%s') /dev/null
    diff <(${CLI_COMMAND[@]} -- '%s' a b c; echo) - <<< 'abc'
}
