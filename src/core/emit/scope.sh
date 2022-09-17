CLI_IMPORT=(
    "cli bash emit expression map"
    "cli core variable get-info"
)

cli::core::emit::scope::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
    Emit a function that globally declares a type and initializes its fields.
EOF
}

cli::core::emit::scope() {
    : "${ARG_SCOPE?'Missing scope.'}"

    local -A CLI_CORE_VARIABLE_EMIT_SCOPE=()
    while read NAME; do
        cli::core::variable::get_info "${NAME}"
        CLI_CORE_VARIABLE_EMIT_SCOPE+=( [${NAME}]="${REPLY}" )
    done

    echo -n "CLI_SCOPE+="
    cli::bash::emit::expression::map CLI_CORE_VARIABLE_EMIT_SCOPE
    echo
}

cli::core::emit::scope::self_test() {
    local ARG_SCOPE='MY_SCOPE'
    
    local -A MY_SCOPE=(
        [MY_STRING]='string'
        [MY_BOOLEAN]='boolean'
        [MY_INTEGER]='integer'
        [MY_ARRAY]='array'
        [MY_MAP]='map'
    )

    diff <(${CLI_COMMAND[@]} -- <<-EOF
		MY_STRING
		MY_BOOLEAN
		MY_INTEGER
		MY_ARRAY
		MY_MAP
		EOF
    ) - <<-EOF
		CLI_SCOPE+=(
		    [MY_ARRAY]="array"
		    [MY_BOOLEAN]="boolean"
		    [MY_INTEGER]="integer"
		    [MY_MAP]="map"
		    [MY_STRING]="string"
		)
		EOF
}
