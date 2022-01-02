#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::name::to_bash::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Convert cli name to bash names. Replace dash and period with underbar.

Description
    \$1 - \$n are the names to covert to bash names. 
    
    MAPFILE contains the result.

    Assert remaining positional arguments match regex \${CLI_REGEX_NAME}.
EOF
}

::cli::name::to_bash::inline() {
    MAPFILE=()
    while (( $# > 0 )); do
        [[ "$1" =~ ${CLI_REGEX_NAME} ]] || cli::assert \
            "Unexpected cli name \"$1\" does not match regex ${CLI_REGEX_NAME}."

        MAPFILE+=( "${1//[-.]/_}" )
        shift
    done
    REPLY=${MAPFILE[0]}
}

cli::name::to_bash::self_test() {
    diff <(${CLI_COMMAND[@]} ---mapfile foo foo-bar .foo) - \
        <<-EOF || cli::assert
			foo
			foo_bar
			_foo
		EOF
}
