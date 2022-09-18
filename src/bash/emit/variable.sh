#! inline

CLI_IMPORT=(
    "cli bash emit initializer array"
    "cli bash emit initializer map"
    "cli bash emit initializer string"
    "cli bash emit statement initialize"
    "cli bash variable get-info"
)

cli::bash::emit::variable::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Variable a declaration and initialization.

Description
    ARG_SCOPE is the scope name.

    \$1 is the variable name.
    \$2 optional are modifier flags (e.g. 'r' for read-only).
EOF
}

cli::bash::emit::variable() {
    local NAME=${1-}
    [[ "${NAME}" ]] || cli::assert 'Missing name.'
    shift

    local FLAGS=${1-}

    cli::bash::variable::get_info "${NAME}" \
        || cli::assert "Variable '${NAME}' not declared."
    FLAGS+=${REPLY}

    if ${REPLY_CLI_BASH_VARIABLE_IS_SCALER}; then
        cli::bash::emit::initializer::string ${NAME}

    elif ${REPLY_CLI_BASH_VARIABLE_IS_MAP}; then
        cli::bash::emit::initializer::map ${NAME}

    elif ${REPLY_CLI_BASH_VARIABLE_IS_ARRAY}; then
        cli::bash::emit::initializer::array ${NAME}

    fi | cli::bash::emit::statement::initialize ${NAME} ${FLAGS}
    
    echo
}

cli::bash::emit::variable::self_test() {

    local MY_STRING='Hello world!'
    local MY_BOOLEAN='true'
    local -i MY_INTEGER=42
    local -a MY_ARRAY=( a b c )
    local -A MY_MAP=( [a]=0 )

    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'declare -- MY_STRING="Hello world!"'
    diff <(${CLI_COMMAND[@]} -- MY_BOOLEAN) - <<< 'declare -- MY_BOOLEAN="true"'
    diff <(${CLI_COMMAND[@]} -- MY_INTEGER) - <<< 'declare -i MY_INTEGER="42"'
    diff <(${CLI_COMMAND[@]} -- MY_ARRAY) - <<-EOF
		declare -a MY_ARRAY=(
		    "a"
		    "b"
		    "c"
		)
		EOF
    diff <(${CLI_COMMAND[@]} -- MY_MAP) - <<-EOF
		declare -A MY_MAP=(
		    [a]="0"
		)
		EOF
}
