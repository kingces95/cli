#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable parse
cli::source cli core variable declare
cli::source cli core variable name resolve
cli::source cli core variable get-info
cli::source cli set test

cli::core::variable::put::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Set a bash variable given a typed variable, a list of fields, and a value.

Description
    Argument $1-n is the type of the variable, followed by a name which is
    extended given the remaining arguments which constitute a path followed
    by the value or key/value if the type is a map.

Arguments
    --                      : Record to put.
EOF
}

cli::core::variable::put::main() {
    local NAME="${1-}"
    cli::core::variable::put "$@"
    cli::dump "${NAME}" "${NAME}_*"
}

cli::core::variable::put() {
    local NAME=${1-}
    shift

    cli::core::variable::get_info "${NAME}" \
        || cli::assert "Variable '${NAME}' not defiend."

    local TYPE="${REPLY}"
    [[ "${TYPE}" ]] || ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED} || cli::assert

    local -n REF="${NAME}"

    # builtin
    if ${REPLY_CLI_CORE_VARIABLE_IS_BUILTIN}; then

        # scaler
        if ${REPLY_CLI_CORE_TYPE_IS_SCALER}; then
            (( $# <= 1 )) || cli::assert \
                "Failed to assign '${1}' to ${TYPE} '${NAME}'." \
                "Expected a record with one or no fields, but got '$#': $@"

            local VALUE

            # boolean
            if ${REPLY_CLI_CORE_TYPE_IS_BOOLEAN}; then
                VALUE="${1-true}"
                [[ "${VALUE}" =~ ^true$|^false$ ]] || \
                    cli::assert "Failed to assign '${VALUE}' to ${TYPE} '${NAME}'."

            # integer
            elif ${REPLY_CLI_CORE_TYPE_IS_INTEGER}; then
                VALUE="${1-0}"
                [[ "${VALUE}" =~ ^[-]?[0-9]+$ ]] || \
                    cli::assert "Failed to assign '${VALUE}' to ${TYPE} '${NAME}'."

            # string
            else
                ${REPLY_CLI_CORE_TYPE_IS_STRING} || cli::assert
                VALUE="${1-}"
            fi

            REF="${VALUE}" 

        # map
        elif ${REPLY_CLI_CORE_TYPE_IS_MAP}; then
            (( $# <= 2 )) || cli::assert \
                "Failed to assign key '${1-}' value '${2-}' in map '${NAME}'." \
                "Expected a record with two or fewer fields, but got $#: $@"

            # no key/value pair
            if (( $# == 0 )); then 
                return
            fi

            local KEY="$1"
            [[ "${KEY}" =~ . ]] || cli::assert \
                "Failed to use empty key to assign '$2' to map '${NAME}'."

            local VALUE="${2-}"

            # map key and maybe a value supplied
            REF+=( ["${KEY}"]="${VALUE}" )

        # array
        else
            ${REPLY_CLI_CORE_TYPE_IS_ARRAY} || cli::assert

            # array element supplied
            (( $# <= 1 )) || cli::assert \
                "Failed to add value '$1' to array '${NAME}'." \
                "Expected a record with one or no fields, but got $@: $@"
            
            # no elements
            if (( $# == 0 )); then 
                return
            fi

            local ELEMENT="$1"
            REF+=( "${ELEMENT}" ) 
        fi

        return
    fi

    ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED} \
        || ${REPLY_CLI_CORE_VARIABLE_IS_USER_DEFINED} \
        || cli::assert

    if (( $# == 0 )); then
        return
    fi

    local KEY="$1"
    shift

    # modified
    if ${REPLY_CLI_CORE_VARIABLE_IS_MODIFIED}; then
        TYPE="${MAPFILE[*]}"

        # add ordinal to map_of map
        if ! cli::set::test REF "${KEY}"; then
            REF+=( ["${KEY}"]=${#REF[@]} )
        fi
    fi

    # resolve variable name
    ARG_TYPE="${TYPE}" \
        cli::core::variable::name::resolve "${NAME}" "${KEY}"
    local NEXT_NAME="${REPLY}"
    local NEXT_TYPE="${MAPFILE[*]}"

    # declare variable
    ARG_TYPE="${NEXT_TYPE}" \
        cli::core::variable::declare "${NEXT_NAME}"

    # set variable
    cli::core::variable::put "${NEXT_NAME}" "$@"
}

cli::core::variable::put::self_test() {
    local -A SCOPE=()
    local ARG_SCOPE='SCOPE'

    dsl() {
        local RESULT="MY_REPLY_CLI_DSL_META"
        ARG_TYPE="cli_help_parse" \
            cli::core::variable::declare "${RESULT}"
    
        cli::core::variable::put "${RESULT}" group "*" type "depth" "string"
        cli::core::variable::put "${RESULT}" group "*" type "max" "string"

        diff <(cli::dump "${RESULT}" "${RESULT}_*") - <<-EOF
			declare -A MY_REPLY_CLI_DSL_META_GROUP=(["*"]="0" )
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_ALIAS=()
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_ALLOW=()
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_DEFAULT=()
			declare -- MY_REPLY_CLI_DSL_META_GROUP_0_POSITIONAL="false"
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_REGEX=()
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_REQUIRE=()
			declare -A MY_REPLY_CLI_DSL_META_GROUP_0_TYPE=([depth]="string" [max]="string" )
			EOF
    }

    escaping() {
            
        local -A SCOPE=(
            ['MY_STRING']='string'
            ['MY_MAP']='map'
            ['MY_ARRAY']='array'
        )

        # string
        local MY_STRING=
        diff <( ${CLI_COMMAND[@]} -- MY_STRING 'Hello world!' ) - \
            <<< 'declare -- MY_STRING="Hello world!"'

        # array
        local -a MY_ARRAY=()
        diff <( ${CLI_COMMAND[@]} -- MY_ARRAY 'a b c' ) - \
            <<< 'declare -a MY_ARRAY=([0]="a b c")'

        # map
        local -A MY_MAP=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP a "b c" ) - \
            <<< 'declare -A MY_MAP=([a]="b c" )'
    }

    builtin() {
            
        local -A SCOPE=(
            ['MY_STRING']='string'
            ['MY_BOOLEAN']='boolean'
            ['MY_INTEGER']='integer'
            ['MY_MAP']='map'
            ['MY_ARRAY']='array'
        )

        # string
        local MY_STRING=
        diff <( ${CLI_COMMAND[@]} -- MY_STRING 'Hello' ) - \
            <<< 'declare -- MY_STRING="Hello"'

        # boolean
        local MY_BOOLEAN=false
        diff <( ${CLI_COMMAND[@]} -- MY_BOOLEAN true ) - \
            <<< 'declare -- MY_BOOLEAN="true"'

        local MY_BOOLEAN=false
        diff <( ${CLI_COMMAND[@]} -- MY_BOOLEAN ) - \
            <<< 'declare -- MY_BOOLEAN="true"'

        # integer
        local -i MY_INTEGER=0
        diff <( ${CLI_COMMAND[@]} -- MY_INTEGER 42 ) - \
            <<< 'declare -i MY_INTEGER="42"'

        # array
        local -a MY_ARRAY=()
        diff <( ${CLI_COMMAND[@]} --- MY_ARRAY a > /dev/null
                ${CLI_COMMAND[@]} -- MY_ARRAY b; ) - \
            <<< 'declare -a MY_ARRAY=([0]="a" [1]="b")'

        # map
        local -A MY_MAP=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP a 0 ) - \
            <<< 'declare -A MY_MAP=([a]="0" )'
    }

    builtin_default() {
            
        local -A SCOPE=(
            ['MY_STRING']='string'
            ['MY_BOOLEAN']='boolean'
            ['MY_INTEGER']='integer'
            ['MY_MAP']='map'
            ['MY_ARRAY']='array'
        )

        # string
        local MY_STRING='Hello world!'
        diff <( ${CLI_COMMAND[@]} -- MY_STRING ) - \
            <<< 'declare -- MY_STRING=""'

        # boolean
        local MY_BOOLEAN=false
        diff <( ${CLI_COMMAND[@]} -- MY_BOOLEAN ) - \
            <<< 'declare -- MY_BOOLEAN="true"'

        # integer
        local -i MY_INTEGER=42
        diff <( ${CLI_COMMAND[@]} -- MY_INTEGER ) - \
            <<< 'declare -i MY_INTEGER="0"'

        # array
        local -a MY_ARRAY=('a')
        diff <( ${CLI_COMMAND[@]} -- MY_ARRAY ) - \
            <<< 'declare -a MY_ARRAY=([0]="a")'

        # map (no key/value)
        local -A MY_MAP=([k]=v)
        diff <( ${CLI_COMMAND[@]} -- MY_MAP) - \
            <<< 'declare -A MY_MAP=([k]="v" )'
   
        # map (no value)
        diff <( ${CLI_COMMAND[@]} -- MY_MAP k) - \
            <<< 'declare -A MY_MAP=([k]="" )'
    }

    indirect() {
            
        local -A SCOPE=(
            ['MY_MAP_OF_STRING']='map_of string'
            ['MY_MAP_OF_BOOLEAN']='map_of boolean'
            ['MY_MAP_OF_INTEGER']='map_of integer'
            ['MY_MAP_OF_MAP']='map_of map'
            ['MY_MAP_OF_ARRAY']='map_of array'
        )

        # string
        local -A MY_MAP_OF_STRING=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_STRING x Hello ) <(
            echo 'declare -A MY_MAP_OF_STRING=([x]="0" )'
            echo 'declare -- MY_MAP_OF_STRING_0="Hello"'
        )

        # boolean
        local -A MY_MAP_OF_BOOLEAN=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_BOOLEAN x true ) <(
            echo 'declare -A MY_MAP_OF_BOOLEAN=([x]="0" )'
            echo 'declare -- MY_MAP_OF_BOOLEAN_0="true"'
        )

        # integer
        local -A MY_MAP_OF_INTEGER=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_INTEGER x 42 ) <(
            echo 'declare -A MY_MAP_OF_INTEGER=([x]="0" )'
            echo 'declare -i MY_MAP_OF_INTEGER_0="42"'
        )

        # array
        local -A MY_MAP_OF_ARRAY=()
        diff <( 
            ${CLI_COMMAND[@]} --- MY_MAP_OF_ARRAY x "a b" > /dev/null
            ${CLI_COMMAND[@]} -- MY_MAP_OF_ARRAY x c 
        ) <(
            echo 'declare -A MY_MAP_OF_ARRAY=([x]="0" )'
            echo 'declare -a MY_MAP_OF_ARRAY_0=([0]="a b" [1]="c")'
        )

        # map
        local -A MY_MAP_OF_MAP=()
        diff <( 
            ${CLI_COMMAND[@]} --- MY_MAP_OF_MAP x a 0 > /dev/null
            ${CLI_COMMAND[@]} --- MY_MAP_OF_MAP x b 1 > /dev/null 
            ${CLI_COMMAND[@]} --- MY_MAP_OF_MAP y a 0 > /dev/null 
            ${CLI_COMMAND[@]} -- MY_MAP_OF_MAP y a 
        ) <(
            echo 'declare -A MY_MAP_OF_MAP=([y]="1" [x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_0=([b]="1" [a]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_1=([a]="" )'
        )
    }

    double_indirect() {
          local -A SCOPE=(
            ['MY_MAP_OF_MAP_OF_STRING']='map_of map_of string'
        )

        local -A MY_MAP_OF_MAP_OF_STRING=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_MAP_OF_STRING x y Hello ) <(
            echo 'declare -A MY_MAP_OF_MAP_OF_STRING=([x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_OF_STRING_0=([y]="0" )'
            echo 'declare -- MY_MAP_OF_MAP_OF_STRING_0_0="Hello"'
        )
    }

    indirect_default() {
            
        local -A SCOPE=(
            ['MY_MAP_OF_STRING']='map_of string'
            ['MY_MAP_OF_BOOLEAN']='map_of boolean'
            ['MY_MAP_OF_INTEGER']='map_of integer'
            ['MY_MAP_OF_ARRAY']='map_of array'
            ['MY_MAP_OF_MAP']='map_of map'
        )

        # string
        local -A MY_MAP_OF_STRING=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_STRING x ) <( \
            echo 'declare -A MY_MAP_OF_STRING=([x]="0" )'
            echo 'declare -- MY_MAP_OF_STRING_0=""'
        )

        # boolean
        local -A MY_MAP_OF_BOOLEAN=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_BOOLEAN x ) <( \
            echo 'declare -A MY_MAP_OF_BOOLEAN=([x]="0" )'
            echo 'declare -- MY_MAP_OF_BOOLEAN_0="true"'
        )

        # integer
        local -A MY_MAP_OF_INTEGER=()
        diff <( ${CLI_COMMAND[@]} -- MY_MAP_OF_INTEGER x ) <( \
            echo 'declare -A MY_MAP_OF_INTEGER=([x]="0" )'
            echo 'declare -i MY_MAP_OF_INTEGER_0="0"'
        )

        # array
        local -A MY_MAP_OF_ARRAY=()
        diff <( 
            ${CLI_COMMAND[@]} -- MY_MAP_OF_ARRAY x
        ) <(
            echo 'declare -A MY_MAP_OF_ARRAY=([x]="0" )'
            echo 'declare -a MY_MAP_OF_ARRAY_0=()'
        )

        # map
        local -A MY_MAP_OF_MAP=()
        diff <( 
            ${CLI_COMMAND[@]} --- MY_MAP_OF_MAP x a > /dev/null
            ${CLI_COMMAND[@]} --- MY_MAP_OF_MAP x b > /dev/null 
            ${CLI_COMMAND[@]} --  MY_MAP_OF_MAP y a 
        ) <( \
            echo 'declare -A MY_MAP_OF_MAP=([y]="1" [x]="0" )'
            echo 'declare -A MY_MAP_OF_MAP_0=([b]="" [a]="" )'
            echo 'declare -A MY_MAP_OF_MAP_1=([a]="" )'
        )
    }

    udt() {
        local -A SCOPE=(
            ['MY_MAP_OF_VERSION']='map_of version'
        )

        declare -A CLI_TYPE_VERSION=(
            ['major']='integer' 
            ['minor']='integer'
        )

        # indirect
        diff <( 
            local -A MY_MAP_OF_VERSION=()
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION x major 1 > /dev/null
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION x minor 2
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="1"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="2"'
        )

        # indirect no key
        diff <( 
            local -A MY_MAP_OF_VERSION=()
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=()'
        )

        # indirect key but no field
        diff <( 
            local -A MY_MAP_OF_VERSION=()
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION x
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="0"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="0"'
        )

        # indirect default
        diff <( 
            local -A MY_MAP_OF_VERSION=()
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION x major 1 > /dev/null
            ${CLI_COMMAND[@]} --- MY_MAP_OF_VERSION x major
        ) <(
            echo 'declare -A MY_MAP_OF_VERSION=([x]="0" )'
            echo 'declare -i MY_MAP_OF_VERSION_0_MAJOR="0"'
            echo 'declare -i MY_MAP_OF_VERSION_0_MINOR="0"'
        )

        # direct
        local -A SCOPE=(
            ['MY_UDT']='udt'
        )

        declare -A CLI_TYPE_UDT=(
            ['positional']='boolean' 
            ['allow']='map_of map' 
            ['version']='version'
        )
        diff <( 
            ${CLI_COMMAND[@]} --- MY_UDT positional true > /dev/null
            ${CLI_COMMAND[@]} --- MY_UDT version minor 2 > /dev/null
            ${CLI_COMMAND[@]} --- MY_UDT version major 1 > /dev/null
            ${CLI_COMMAND[@]} --- MY_UDT allow color white > /dev/null
            ${CLI_COMMAND[@]} --- MY_UDT allow color black
        ) <(
            echo 'declare -A MY_UDT_ALLOW=([color]="0" )' 
            echo 'declare -A MY_UDT_ALLOW_0=([black]="" [white]="" )' 
            echo 'declare -- MY_UDT_POSITIONAL="true"' 
            echo 'declare -i MY_UDT_VERSION_MAJOR="1"' 
            echo 'declare -i MY_UDT_VERSION_MINOR="2"'
        )
    }

    missing_field() {

        # indirect
        set +e
        declare -A CLI_TYPE_VERSION=(['major']='integer' ['minor']='integer')
        declare -A MY_MAP_OF_VERSION=()
        declare -p \
            CLI_TYPE_VERSION \
            MY_MAP_OF_VERSION \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x major 1 \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x minor 2 \
            | ${CLI_COMMAND[@]} -s --name MY_MAP_OF_VERSION --type 'map_of version' -- x missing 3 \
              2>&1 >/dev/null \
            | assert::error_message "Field 'missing' not found in 'version' fields: { minor major }."
        assert::failed
        set -e
    }

    bad_value() {
        set +e
        declare MY_BOOLEAN
        declare -p MY_BOOLEAN \
            | ${CLI_COMMAND[@]} -s --type boolean --name MY_BOOLEAN -- 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'bad' to boolean 'MY_BOOLEAN'." \
                "'bad' does not match regex '^$|^true$|^false$'."
        assert::failed

        declare -i MY_INTEGER
        declare -p MY_INTEGER \
            | ${CLI_COMMAND[@]} -s --type integer --name MY_INTEGER -- 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'bad' to integer 'MY_INTEGER'." \
                "'bad' does not match regex '^$|^[-]?[0-9]+$'."
        assert::failed

        declare -A MY_MAP
        declare -p MY_MAP \
            | ${CLI_COMMAND[@]} -s --type map --name MY_MAP -- '' 'val' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to use empty key to assign 'val' to map 'MY_MAP'." \
                "'' does not match regex '.'."
        assert::failed
        set -e
    }

    too_many_values() {
        set +e
        declare MY_BOOLEAN
        declare -p MY_BOOLEAN \
            | ${CLI_COMMAND[@]} -s --type boolean --name MY_BOOLEAN -- 'true' 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign 'true' to boolean 'MY_BOOLEAN'." \
                "Expected a record with one or no fields, but got 'true bad'."
        assert::failed

        declare -A MY_MAP
        declare -p MY_MAP \
            | ${CLI_COMMAND[@]} -s --type map --name MY_MAP -- 'key' 'value' 'bad' \
              2>&1 >/dev/null \
            | assert::error_message "Failed to assign value 'value' to key 'key' in map 'MY_MAP'." \
                "Expected a record with two or fewer fields, but got 'key value bad'."
        assert::failed
        set -e
    }

    dsl
    escaping
    builtin
    builtin_default

    indirect
    double_indirect
    indirect_default

    udt
return

    bad_value
    too_many_values
    missing_field
}
