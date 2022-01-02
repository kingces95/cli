#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli name to-bash
cli::source cli bash join

cli::name::to_main::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Verifies cli names convert them to bash names.

Description
    Argument \$1 is the name of the array to append results. 
    
    Assert remaining positional arguments match regex '${CLI_REGEX_NAME}'.

    Replace dashes and period with underbar and store the result in \$1.
EOF
}

::cli::name::to_main::inline() {
    ::cli::name::to_bash::inline "$@"
    ::cli::bash::join::inline "::" "${MAPFILE[@]}" 'main'
}

cli::name::to_main::self_test() {
    diff <(${CLI_COMMAND[@]} ---reply foo foo-bar .foo) - \
        <<< 'foo::foo_bar::_foo::main' || cli::assert
}
