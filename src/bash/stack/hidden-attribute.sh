#! inline

cli::bash::stack::hidden_attribute::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Prevents the target method from appearing in stack traces.
EOF
}

# declare -A CLI_TYPE_CLI_BASH_STACK_HIDDEN_ATTRIBUTE=()

cli::bash::stack::hidden_attribute::main() {
    cli::export CLI_TYPE_CLI_BASH_STACK
}

cli::bash::stack::hidden_attribute::self_test() {
    :
}