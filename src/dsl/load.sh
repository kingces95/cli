#! inline

CLI_IMPORT=(
    "cli core type to-bash"
    "cli core variable declare"
    "cli core variable load"
    "cli core variable put"
    "cli core variable read"
    "cli core variable save"
    "cli core variable write"
)

cli::dsl::load::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}

Description
    Loads metadata into a structure more suitable for consumption at runtime.
EOF
}

swap() {
    awk "{ t = \$$1; \$$1 = \$$2; \$$2 = t; print }"
}

transform() {
    local INDEX=$(( $1 - 1 ))
    while read -a FIELDS; do
        $2 "${FIELDS[${INDEX}]}"
        FIELDS[${INDEX}]="${REPLY}"
        echo "${FIELDS[@]}"
    done
}

cli::dsl::load::main() {
    ARG_SCOPE="CLI_SCOPE" \
    ARG_META='MY_META' \
    ARG_NAME='MY_META_TABLES' \
        cli::dsl::load
}

cli::dsl::load() {
    local SCOPE_NAME="${ARG_SCOPE}"
    local RESULT="${ARG_NAME}"
    local PARSE="CLI_HELP_PARSE"

    # declare temp variable to hold inbound stream
    ARG_TYPE="cli_help_parse" \
        cli::core::variable::declare ${PARSE}

    # load stream
    cli::core::variable::read ${PARSE}

    ARG_TYPE="cli_meta" \
        cli::core::variable::declare ${RESULT}

    # alias' must be unique across all group
    cli::core::variable::write ${PARSE}_GROUP \
        | awk '$2=="alias" { print $3, $4 }' \
        | sort \
        | tee >(
            sort -uC || cli::assert 'Duplicate alias detected.'
        ) | cli::core::variable::read ${RESULT}_ALIAS

    # group specific metadata; e.g. the group id is not '*'
    cli::core::variable::write ${PARSE}_GROUP \
        | awk '$1 != "*" && $2 != "alias"' \
        | cli::core::variable::read ${RESULT}_GROUP

    local -n GROUP_REF=${RESULT}_GROUP

    local -a GROUP_NAMES=( "${!GROUP_REF[@]}" )
    if (( ${#GROUP_NAMES[@]} == 0 )); then
        GROUP_NAMES=( '*' )
    fi

    local GROUP_NAME
    for GROUP_NAME in "${GROUP_NAMES[@]}"; do

        cli::core::variable::write ${PARSE}_GROUP \
            | awk '$2 != "alias"' \
            | awk -v group="${GROUP_NAME}" '$1 == "*" { $1 = group; print; }' \
			| cli::core::variable::read ${RESULT}_GROUP
    done

    cli::core::variable::write "${RESULT}"
}

cli::dsl::load::self_test() (
    diff <(cli sample simple -h \
        | cli dsl tokenize \
        | cli dsl parse \
        | cli dsl meta \
        | ${CLI_COMMAND[@]} -- 
    ) - <<-EOF
		alias p my-props
		alias l my-list
		alias h help
		alias f fruit
		alias d dump
		group * require header
		group * default fruit banana
		group * regex header ^[A-Z][A-Za-z0-9_]*$
		group * positional
		group * type my-list array
		group * type run-as string
		group * type fruit string
		group * type my-props map
		group * type self-test boolean
		group * type help boolean
		group * type header string
		group * type dump boolean
		group * allow fruit orange
		group * allow fruit banana
		EOF

    diff <(cli sample kitchen-sink -h \
        | cli dsl tokenize \
        | cli dsl parse \
        | cli dsl meta \
        | ${CLI_COMMAND[@]} -- 
    ) - <<-EOF
		alias p my-props
		alias l my-list
		alias i id
		alias h help
		alias f fruit
		alias d dump
		group id require header
		group id default fruit banana
		group id regex header ^[A-Z][A-Za-z0-9_]*$
		group id positional
		group id type my-list array
		group id type run-as string
		group id type fruit string
		group id type my-props map
		group id type id string
		group id type self-test boolean
		group id type help boolean
		group id type header string
		group id type dump boolean
		group id allow fruit orange
		group id allow fruit banana
		group name require header
		group name default fruit banana
		group name regex header ^[A-Z][A-Za-z0-9_]*$
		group name positional
		group name type my-list array
		group name type run-as string
		group name type fruit string
		group name type my-props map
		group name type self-test boolean
		group name type help boolean
		group name type header string
		group name type dump boolean
		group name type name string
		group name type namespace string
		group name allow fruit orange
		group name allow fruit banana
		EOF
)
