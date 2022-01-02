#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::run_as::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Run a command as a different user.

Arguments
    --command -c [Required] : The path to the command.
    --user -u    [Required] : The name of the user.
    --                      : Arguments.
EOF
    cat << EOF

Examples
    Test for the function 'inline'.
        ${CLI_COMMAND[@]} --name inline
EOF
}

cli::run_as() {
    local -a args=($(printf %q "${arg_command}"))

    for i in "$@"; do
        args+=( $(printf %q "${i}") )
    done

    sudo su "${arg_user}" -c "${args[*]}"
}

cli::run_as::self_test() {
    return
    # TODO create user, test, delete user
}
