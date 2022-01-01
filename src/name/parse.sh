#!/usr/bin/env CLI_NAME=cli bash-cli-part

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Return arguments that conform to a cli name.

Description
    Arguments are whatever the user passed on the command line.

    MAPFILE contains the first arguments that match "${CLI_REGEX_NAME}".
EOF
}

::cli::name::parse::inline() {
    MAPFILE=()
    while [[ "${1-}" =~ ${CLI_REGEX_NAME} ]]; do
        MAPFILE+=( "$1" )
        shift
    done
}

cli::name::parse::self_test() {
    diff <(${CLI_COMMAND[@]} ---mapfile foo foo-bar .foo --arg) - \
        <<-EOF || cli::assert
			foo
			foo-bar
			.foo
		EOF
}
