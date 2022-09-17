
cli::path::make_absolute::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Make a path absolute.

Description
    Argument \$1 is the name of the variable to store the absolute path.

    Argument \$2 is the path. If the path is already absolute, then it
    is assigned to the variable named by \$1, otherwise the present working
    directory is prepened and then assigned to \$1.

    If \$2 is empty, then the present working directory is returned.

    If \$2 begins with './', then that is stripped before prepending the
    present working directory.
EOF
}

cli::path::make_absolute() {
    if [[ ! "${1-}" ]]; then
        REPLY="${PWD}"

    elif [[ ! "$1" =~ ^/ ]]; then
        REPLY="${PWD}/${1##./}"

    else
        REPLY="$1"
    fi
}

cli::path::make_absolute::self_test() {
    [[ "$(${CLI_COMMAND[@]} ---reply)" == "${PWD}" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply "foo/bar")" == "${PWD}/foo/bar" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply "./foo/bar")" == "${PWD}/foo/bar" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply "/foo/bar")" == "/foo/bar" ]] || cli::assert
}
