#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::bash::variable::declare_enum::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Declare an enum. 

Arguments
    Argument \$1 is the enum name and subsequent arguments are enum symbols. 

    Declare a global readonly array containing the symbols. Declare a global
    variable for each symbol whose name is the underbar join of the enum
    name and the symbol with an integer value corresponding to the position
    of the symbol in the global readonly array.

Example
    ${CLI_COMMAND[@]} -- MY_TOKENS STRING INTEGER BOOLEAN
EOF
}

cli::bash::variable::declare_enum::main() {
    cli::bash::variable::declare_enum "$@";
    declare -p "$1"
    declare -p $(printf " $1_%s" "${@:2}")
}

cli::bash::variable::declare_enum() {
    declare NAME=$1
    shift

    declare -gra "${NAME}=( $* )"

    local COUNT=$#
    for ((i=0; i<${COUNT}; i++)); do
        declare -gr "${NAME}_$1=$i"
        shift 
    done
}

cli::bash::variable::declare_enum::self_test() {
    diff <(${CLI_COMMAND[@]} -- MY_TOKENS STRING INTEGER BOOLEAN) - <<-EOF || cli::assert
		declare -ar MY_TOKENS=([0]="STRING" [1]="INTEGER" [2]="BOOLEAN")
		declare -r MY_TOKENS_STRING="0"
		declare -r MY_TOKENS_INTEGER="1"
		declare -r MY_TOKENS_BOOLEAN="2"
		EOF
}
