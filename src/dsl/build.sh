CLI_IMPORT=(
    "cli core emit global"
    "cli core variable declare"
    "cli core variable read"
    "cli dsl load"
)

cli::dsl::build::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Summary
    Declare cli_meta variable and initialize it with help.

Description
    ARG_SCOPE is the name of the scope.
    ARG_CLI_DSL_DECLARE_HELP is an optional path help (ie copy of stdin).
    ARG_CLI_DSL_DECLARE_TOKENIZE is an optional path to tokenized help.
    ARG_CLI_DSL_DECLARE_PARSE is an optional path to parsed help.
    ARG_CLI_DSL_DECLARE_META is an optional path to meta help.
    ARG_CLI_DSL_DECLARE_LOAD is an optional path to load help.
    ARG_CLI_DSL_DECLARE_EMIT is an optional path to emit help.

    \$1 is the name of the global variable to declare.
EOF
}

cli::dsl::build::main() (
    [[ "${ARG_SCOPE-}" ]] || cli::assert 'Missing scope.'

    local NAME=${1-}
    [[ "${NAME}" ]] || cli::assert 'Missing name.'

    ARG_TYPE='cli_meta'
        cli::core::variable::declare ${NAME}

    cat | tee "${ARG_CLI_DSL_DECLARE_HELP-/dev/null}" \
        | cli dsl tokenize | tee "${ARG_CLI_DSL_DECLARE_TOKENIZE-/dev/null}" \
        | cli dsl parse | tee "${ARG_CLI_DSL_DECLARE_PARSE-/dev/null}" \
        | cli dsl meta | tee "${ARG_CLI_DSL_DECLARE_META-/dev/null}" \
        | cli dsl load -- | tee "${ARG_CLI_DSL_DECLARE_LOAD-/dev/null}" \
        | cli::core::variable::read ${NAME}

	cli::core::emit::global ${NAME}
)

cli::dsl::build::self_test() (
    local -A MY_SCOPE=()
    local ARG_SCOPE=MY_SCOPE

    cli::temp::file
    local ARG_CLI_DSL_DECLARE_TOKENIZE="${REPLY}"

    cli::temp::file
    local ARG_CLI_DSL_DECLARE_PARSE="${REPLY}"

    cli::temp::file
    local ARG_CLI_DSL_DECLARE_META="${REPLY}"

    cli::temp::file
    local ARG_CLI_DSL_DECLARE_LOAD="${REPLY}"

    cli::temp::file
    local ARG_CLI_DSL_DECLARE_EMIT="${REPLY}"

    local NAME='MY_META'

    cli eg simplest -h \
        | ${CLI_COMMAND[@]} -- "${NAME}" \
		> "${ARG_CLI_DSL_DECLARE_EMIT}"

    diff <(cat "${ARG_CLI_DSL_DECLARE_TOKENIZE}") - <<-EOFF
		ARGUMENTS 7 1 
		NAME 8 1 help
		ALIAS 8 2 h
		FLAG 8 3 
		NAME 9 1 self-test
		FLAG 9 2 
		EOF 10 7 
		EOFF

    diff <(cat "${ARG_CLI_DSL_DECLARE_PARSE}") - <<-EOFF
		* . ARGUMENTS *
		* help NAME help
		* help ALIAS h
		* help FLAG 
		* help TYPE boolean
		* self-test NAME self-test
		* self-test FLAG 
		* self-test TYPE boolean
		EOFF

    diff <(cat "${ARG_CLI_DSL_DECLARE_META}") - <<-EOFF
		group * alias h help
		group * type self-test boolean
		group * type help boolean
		EOFF

    diff <(cat "${ARG_CLI_DSL_DECLARE_LOAD}") - <<-EOFF
		alias h help
		group * type self-test boolean
		group * type help boolean
		EOFF

    diff <(cat "${ARG_CLI_DSL_DECLARE_EMIT}") - <<-EOFF
		declare -gA MY_META_ALIAS=(
		    [h]="help"
		)
		declare -gA MY_META_GROUP=(
		    ["*"]="0"
		)
		declare -gA MY_META_GROUP_0_ALLOW=()
		declare -gA MY_META_GROUP_0_DEFAULT=()
		declare -g MY_META_GROUP_0_POSITIONAL="false"
		declare -gA MY_META_GROUP_0_REGEX=()
		declare -gA MY_META_GROUP_0_REQUIRE=()
		declare -gA MY_META_GROUP_0_TYPE=(
		    [help]="boolean"
		    [self-test]="boolean"
		)
		
		CLI_SCOPE+=(
		    [MY_META]="cli_meta"
		    [MY_META_ALIAS]="map"
		    [MY_META_GROUP]="map_of cli_meta_group"
		    [MY_META_GROUP_0]="cli_meta_group"
		    [MY_META_GROUP_0_ALLOW]="map_of map"
		    [MY_META_GROUP_0_DEFAULT]="map"
		    [MY_META_GROUP_0_POSITIONAL]="boolean"
		    [MY_META_GROUP_0_REGEX]="map"
		    [MY_META_GROUP_0_REQUIRE]="map"
		    [MY_META_GROUP_0_TYPE]="map"
		)
		EOFF
)
