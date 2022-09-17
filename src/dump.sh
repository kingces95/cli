
cli::dump::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copies stdin to a temporary file and echos the path to the file.
EOF
}

cli::dump() {
    :
}

cli::self_test() {
    :
}
