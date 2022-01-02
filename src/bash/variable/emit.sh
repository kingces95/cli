#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli bash variable list
# cli::source cli bash emit variable

cli::bash::variable::emit::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Like 'declare -p' except accepts wild cards.

Description
    Positional arguments \$1, \$2, etc are variable names that optionally end in '*'.

    All variables which match any of the positional arguments are printed like 
    they would be with 'declare -p. If a variable does not exist, nothing is printed.

Arguments
    --                      : The variables to emit.
EOF
}

cli::bash::variable::emit::inline() {
    cli::bash::variable::list::inline "$@" \
        | while read; do declare -p ${REPLY}; done

    # set "${MAPFILE[@]}"
    # while (( $# > 0 )); do
    #     cli::bash::emit::variable::inline "$1"
    #     shift
    # done
}

cli::bash::variable::emit::self_test() (
    diff <(${CLI_COMMAND[@]} --) /dev/null
    diff <(${CLI_COMMAND[@]} -- MY_NOT_DEFINED) /dev/null
    diff <(${CLI_COMMAND[@]} -- 'MY_NOT_DEFINED*') /dev/null

    # declared
    local MY_DECL_STRING
    local -a MY_DECL_ARRAY
    local -A MY_DECL_MAP
    local -i MY_DECL_NUMBER

    # declared and initialized
    local MY_EMPTY_STRING=""
    local -a MY_EMPTY_ARRAY=()
    local -A MY_EMPTY_MAP=()

    # declared, initialized, and set
    local MY_STRING='Hello world!'
    local -a MY_ARRAY=(a)
    local -A MY_MAP=([a]=0)
    local -i MY_NUMBER=42

    diff <(${CLI_COMMAND[@]} -- MY_DECL_ARRAY MY_DECL_MAP MY_DECL_STRING MY_DECL_NUMBER) /dev/null
    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'declare -- MY_STRING="Hello world!"'

    diff <(${CLI_COMMAND[@]} -- 'MY_*') \
        - <<-EOF
		declare -a MY_ARRAY=([0]="a")
		declare -a MY_EMPTY_ARRAY=()
		declare -A MY_EMPTY_MAP=()
		declare -- MY_EMPTY_STRING=""
		declare -A MY_MAP=([a]="0" )
		declare -i MY_NUMBER="42"
		declare -- MY_STRING="Hello world!"
		EOF

    diff <(${CLI_COMMAND[@]} -- MY_ARRAY MY_EMPTY_ARRAY MY_EMPTY_MAP MY_EMPTY_STRING MY_MAP MY_NUMBER MY_STRING) \
        - <<-EOF
		declare -a MY_ARRAY=([0]="a")
		declare -a MY_EMPTY_ARRAY=()
		declare -A MY_EMPTY_MAP=()
		declare -- MY_EMPTY_STRING=""
		declare -A MY_MAP=([a]="0" )
		declare -i MY_NUMBER="42"
		declare -- MY_STRING="Hello world!"
		EOF
)
