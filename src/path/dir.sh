#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Get the directory of a path.

Description
    Argument \$1 is a unix path. 

    REPLY is the directory of the path.
EOF
}

::cli::path::dir::inline() { 
    REPLY="$(dirname $1)"
}

cli::path::dir::self_test() {
    [[ "$(${CLI_COMMAND[@]} ---reply /foo)" == "/" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply /foo/)" == "/" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply foo/)" == "." ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ./foo-bar)" == "." ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply foo/bar)" == "foo" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ../..)" == ".." ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ../)" == "." ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ..)" == "." ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply /)" == "/" ]] || cli::assert
    [[ "$(${CLI_COMMAND[@]} ---reply ///)" == "/" ]] || cli::assert
}
