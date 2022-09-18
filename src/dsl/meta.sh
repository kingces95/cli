CLI_IMPORT=(
    "cli core variable declare"
    "cli core variable put"
    "cli core variable write"
)

cli::dsl::meta::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

    Given a stream of command line productions produce a stream of
    the following form:

        struct meta {
            map default
            array require
            map_of map allow
            map alias
            map implicit_value
            boolean positional
        }

    'require' is an array of required options

    'default' is an associative array of default values which are
    assigned when the option is not present on the command line. All known
    options must have a default.

    'implicit_value' is an associatie array of implicit values which
    are assigned when the option is present on the command line but no value
    is supplied or the value is the empty string.

    'alias' is an assoicative array of aliases, typically a single 
    letter. 

    'allow' is an associative array of space delimited allowed 
    values for a given option. 

    'positional' is a boolean and specifies if positional arguments 
    are accepted.
EOF
}

cli::dsl::meta::main() { 
    local -A SCOPE=()
    local ARG_SCOPE="SCOPE"

    local RESULT="REPLY_CLI_DSL_META"
    ARG_TYPE="cli_help_parse" \
        cli::core::variable::declare "${RESULT}"

    local group
    local name
    local production

    # productions are sorted by group + key
    while read group key production_name identifier; do
        production="CLI_DSL_PRODUCTION_${production_name}"
        production=${!production}

        # argument group
        if (( production == CLI_DSL_PRODUCTION_ARGUMENTS )); then
            name=
            group="${identifier}"

        # arguments
        elif (( production == CLI_DSL_PRODUCTION_NAME )); then
            name="${identifier}"
            # cli::core::variable::put named "${group}" "${name}"
            # cli::put STRUCT named "${group}" "${name}"

        # anyargs
        elif (( production == CLI_DSL_PRODUCTION_ANYARGS )); then
            cli::core::variable::put "${RESULT}" group "${group}" positional true

        # alias
        elif (( production == CLI_DSL_PRODUCTION_ALIAS )); then
            cli::core::variable::put "${RESULT}" group "${group}" alias "${identifier}" "${name}"

        # default
        elif (( production == CLI_DSL_PRODUCTION_DEFAULT )); then
            cli::core::variable::put "${RESULT}" group "${group}" default "${name}" "${identifier}"

        # regex
        elif (( production == CLI_DSL_PRODUCTION_REGEX )); then
            cli::core::variable::put "${RESULT}" group "${group}" regex "${name}" "${identifier}"

        # type
        elif (( production == CLI_DSL_PRODUCTION_TYPE )); then
            cli::core::variable::put "${RESULT}" group "${group}" type "${name}" "${identifier}"

        # require
        elif (( production == CLI_DSL_PRODUCTION_REQUIRED )); then
            cli::core::variable::put "${RESULT}" group "${group}" require "${name}"

        # flag
        # elif (( production == CLI_DSL_PRODUCTION_FLAG )); then
        #     cli::put STRUCT default "${group}" "${name}" false
        #     cli::put STRUCT implicit_value "${group}" "${name}" true
        #     cli::put STRUCT allow "${group}" "${name}" true
        #     cli::put STRUCT allow "${group}" "${name}" false

        # allow
        elif (( production == CLI_DSL_PRODUCTION_ALLOWED_VALUE )); then
            cli::core::variable::put "${RESULT}" group "${group}" allow "${name}" "${identifier}"

        # else
        #     cli::assert "Unknown production ${production_name}."
        fi

    done

    cli::core::variable::write "${RESULT}"
}

cli::dsl::meta::self_test() {
    diff <(cli sample kitchen-sink -h \
            | cli dsl tokenize \
            | cli dsl parse \
            | cli dsl meta \
            | sort
        ) \
        <(cat <<-EOF
			group * alias d dump
			group * alias f fruit
			group * alias h help
			group * alias l my-list
			group * alias p my-props
			group * allow fruit banana
			group * allow fruit orange
			group * default fruit banana
			group * positional
			group * regex header ^[A-Z][A-Za-z0-9_]*$
			group * require header
			group * type dump boolean
			group * type fruit string
			group * type header string
			group * type help boolean
			group * type my-list array
			group * type my-props map
			group * type run-as string
			group * type self-test boolean
			group id alias i id
			group id type id string
			group name type name string
			group name type namespace string
			EOF
        )
}
