
cli::bash::array::pop::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return positional arguments less the last one in MAPFILE.
EOF
}

cli::bash::array::pop() {
    (( $# > 0 )) || cli::assert 'Stack empty.'
    MAPFILE=( ${@:1:$((${#@}-1))} )
}

cli::bash::array::pop::self_test() {
    diff <(${CLI_COMMAND[@]} ---mapfile a) - < /dev/null || cli::assert
    diff <(${CLI_COMMAND[@]} ---mapfile a b) - <<< 'a' || cli::assert
}
