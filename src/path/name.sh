
cli::path::name::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Get the name of a path.

Description
    Argument \$1 is a unix path.

    REPLY is the name of the path.
EOF
}

cli::path::name() { 
    REPLY="${1##*/}"; 
}

cli::path::name::self_test() {
    [[ "$(${CLI_COMMAND[@]} ---reply /foo)" == "foo" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ./foo-bar)" == "foo-bar" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply foo/bar)" == "bar" ]] || cli::assert
}
