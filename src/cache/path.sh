#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli path dir"
    "cli path name"
)

cli::cache::path::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Get a command's cache directory.

Arguments
    \$1 is the path to a command.

    REPLY is the cache directory of the command.
EOF
}

cli::cache::path() {
    cli::path::name "$1"
    local NAME="${REPLY}"

    cli::path::dir "$1"
    local DIR="${REPLY}"

    REPLY="${DIR}/.cli/${NAME}"
}

cli::cache::path::self_test() {
    [[ "$(${CLI_COMMAND[@]} ---reply foo/bar)" == 'foo/.cli/bar' ]] || cli::assert
}
