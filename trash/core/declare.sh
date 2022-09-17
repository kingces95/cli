CLI_IMPORT=(
    "cli bash variable emit"
    # "cli core struct emit"
    # "cli core type is-scaler"
    "cli core variable declare"
    "cli core variable put"
)

# Arguments when --print-struct
#     --print-struct -s    [Flag] : Print structs
#     --                          : Struct names

# Arguments when --print
#     --print -p           [Flag] : Print variables
#     --                          : Variable names

# Arguments when --type
#     --type -t                   : Name of type
#     --name -n        [Optional] : Name of variable
#     --field -f     [Properties] : Fields of type
#     --                          : Value

cli::core::declare::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Declare a variable of a given type.

Description
        cli::define_type --name table  \\
            | cli::define_field --name allow --type Map --path A \\
            | cli::define_field --name require --type Map \\
            | cli::emit_type \\
            | source /dev/stdin
        # declare -A CLI_TYPE_TABLE=( [allow]='map_of Map' [require]=Map )

        cli type declare --prefix meta --name param --type table
        # declare -A CLI_PREFIX_META=( [param]=table )
        # declare -A META_PARAM_ALLOW=()
        # declare -A META_PARAM_REQUIRE=()
        # declare -A META_PARAM=( [allow]=META_PARAM_ALLOW [require]=META_PARAM_REQUIRE )

Redefinition
    Bash supports redefinition without clobbering existing values. For example:

        \$ declare -a my_array=( a )
        \$ declare -a my_array
        \$ echo \${my_array[@]}
        a

    Likewise, declare supports redefinition without clobbering existing values. 
    For example:

        \$ ${CLI_COMMAND[@]} --name my_array --type array \\
            | ${CLI_COMMAND[@]} --name my_array -- a \\
            | ${CLI_COMMAND[@]} --name my_array --type array
        \$ echo \${my_array[@]}
        a

    Redefinition that changes type is sometimes allowed by bash, but disallowed
    in all cases by declare.

Arguments
    --print -p       [Flag] : Emit the type, scope, and variable recursively so
                              that it might be sourced.
    --read -r        [Flag] : Read records from stdin into the variable.
    --                      : A record to put into the variable.
EOF
}

cli::core::declare() {
    : ${arg_name:?}
    : ${arg_type=}
    : ${arg_read=false}
    : ${arg_print=false}

    # declare scope
    declare -gA CLI_SCOPE
    local current_type=${CLI_SCOPE[${arg_name}]-}

    # type specified
    if [[ -n ${arg_type} ]]; then

        # no previous declaration
        if [[ -z ${current_type} ]]; then

            # declare variable
            CLI_SCOPE+=( [${arg_name}]=${arg_type} )
            current_type=${arg_type}

            # TODO: Every variable of a UDT should be added to CLI_SCOPE
            # not just the root variable. Once done, cli dsl load can be
            # simplified

            # initialize variable
            ARG_NAME=${arg_name} \
            ARG_TYPE=${arg_type} \
                cli::core::variable::declare
        fi

        cli::assert \
            "[[ \"${current_type}\" == \"${arg_type}\" ]]" \
            "Unexpected redeclaration of '${arg_name}'" \
            "type from '${current_type}' to '${arg_type}'."
    fi

    if [[ -z "${current_type}" ]]; then
        cli::stderr::fail "Unexpected failure to find type for variable '${arg_name}' in CLI_SCOPE."
    fi

    # read
    if ${arg_read}; then
        while read -a REPLY; do
            arg_type=${current_type} \
            arg_read=false \
            arg_print=false \
            arg_name=${arg_name} \
                cli::core::declare "${REPLY[@]}"
        done
    fi

    # put
    if (( $# > 0 )); then
        ARG_NAME=${arg_name} \
        ARG_TYPE=${current_type} \
            cli::core::variable::put "$@"
    fi

    # print
    if ${arg_print}; then

        # type (transitive)
        # local -A visited=()
        # arg_type=${current_type} \
        # arg_visited=visited \
        #     cli::core::struct::emit

        # scope
        echo "declare -A CLI_SCOPE+=([${arg_name}]=\"${current_type}\" )"

        # value
        cli::bash::emit "${arg_name}" "${arg_name}_*"
    fi
}

cli::core::declare::main() {
    if ${arg_source}; then
        source /dev/stdin
    fi

    inline "$@"

    if ! ${arg_print}; then
        cli::bash::emit 'CLI_TYPE_*' 'CLI_SCOPE' "${arg_name}" "${arg_name}_*"
    fi
}

cli::core::declare::self_test() (

    read_records() {

        # string
        echo 'hi' \
            | ${CLI_COMMAND[@]} --read --name MY_STRING --type string --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_STRING]="string" )' \
                'declare -- MY_STRING="hi"'

        # string (from stdin and as positional args)
        echo 'hi' \
            | ${CLI_COMMAND[@]} --read --name MY_STRING --type string --print -- 'there' \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_STRING]="string" )' \
                'declare -- MY_STRING="there"'

        # integer
        echo '42' \
            | ${CLI_COMMAND[@]} --read --name MY_INTEGER --type integer --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_INTEGER]="integer" )' \
                'declare -i MY_INTEGER="42"'

        # boolean
        echo 'true' \
            | ${CLI_COMMAND[@]} --read --name MY_BOOLEAN --type boolean --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_BOOLEAN]="boolean" )' \
                'declare -- MY_BOOLEAN="true"'

        # array
        printf '%s\n' a b c \
            | ${CLI_COMMAND[@]} --read --name MY_ARRAY --type array --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_ARRAY]="array" )' \
                'declare -a MY_ARRAY=([0]="a" [1]="b" [2]="c")'

        # map
        echo 'k v' \
            | ${CLI_COMMAND[@]} --read --name MY_MAP --type map --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP]="map" )' \
                'declare -A MY_MAP=([k]="v" )'

        # map_of builtin
        echo 'n k v' \
            | ${CLI_COMMAND[@]} --read --name MY_MAP_OF_MAP --type "map_of map" --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP_OF_MAP]="map_of map" )' \
                'declare -A MY_MAP_OF_MAP=([n]="0" )' \
                'declare -A MY_MAP_OF_MAP_0=([k]="v" )'

        # map_of map_of map
        printf '%s\n' \
            'default color black' \
            'allow color black' \
            'allow color white' \
            | ${CLI_COMMAND[@]} --read --name MY_META --type "map_of map_of map" --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_META]="map_of map_of map" )' \
                'declare -A MY_META=([default]="0" [allow]="1" )' \
                'declare -A MY_META_0=([color]="0" )' \
                'declare -A MY_META_0_0=([black]="" )' \
                'declare -A MY_META_1=([color]="0" )' \
                'declare -A MY_META_1_0=([black]="" [white]="" )'

        # name collision
        ${CLI_COMMAND[@]} --name VAR --type 'map_of map_of string' \
            | ${CLI_COMMAND[@]} --source --name VAR -- foo bar_baz x \
            | ${CLI_COMMAND[@]} --source --name VAR -- foo_bar baz y \
            | ${CLI_COMMAND[@]} --source --name VAR --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([VAR]="map_of map_of string" )' \
                'declare -A VAR=([foo]="0" [foo_bar]="1" )' \
                'declare -A VAR_0=([bar_baz]="0" )' \
                'declare -- VAR_0_0="x"' \
                'declare -A VAR_1=([baz]="0" )' \
                'declare -- VAR_1_0="y"'
    }

    builtin_default() {

        # string
        ${CLI_COMMAND[@]} --name MY_STRING --type string --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_STRING]="string" )' \
                'declare -- MY_STRING=""'

        # integer
        ${CLI_COMMAND[@]} --name MY_INTEGER --type integer --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_INTEGER]="integer" )' \
                'declare -i MY_INTEGER="0"'

        # boolean
        ${CLI_COMMAND[@]} --name MY_BOOLEAN --type boolean --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_BOOLEAN]="boolean" )' \
                'declare -- MY_BOOLEAN="false"'

        # array
        ${CLI_COMMAND[@]} --name MY_ARRAY --type array --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_ARRAY]="array" )' \
                'declare -a MY_ARRAY=()'

        # map
        ${CLI_COMMAND[@]} --name MY_MAP --type map --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP]="map" )' \
                'declare -A MY_MAP=()'

        # map_of
        ${CLI_COMMAND[@]} --name MY_MAP_OF_STRING --type "map_of string" --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP_OF_STRING]="map_of string" )' \
                'declare -A MY_MAP_OF_STRING=()'
    }

    builtin_assign() {

        # string
        ${CLI_COMMAND[@]} --name MY_STRING --type string --print -- hi \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_STRING]="string" )' \
                'declare -- MY_STRING="hi"'

        # integer
        ${CLI_COMMAND[@]} --name MY_INTEGER --type integer --print -- 42 \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_INTEGER]="integer" )' \
                'declare -i MY_INTEGER="42"'

        # boolean
        ${CLI_COMMAND[@]} --name MY_BOOLEAN --type boolean --print -- true \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_BOOLEAN]="boolean" )' \
                'declare -- MY_BOOLEAN="true"'

        # array
        ${CLI_COMMAND[@]} --name MY_ARRAY --type array --print -- a b c \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_ARRAY]="array" )' \
                'declare -a MY_ARRAY=([0]="a" [1]="b" [2]="c")'

        # map
        ${CLI_COMMAND[@]} --name MY_MAP --type map --print -- k v \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP]="map" )' \
                'declare -A MY_MAP=([k]="v" )'

        # map_of builtin
        ${CLI_COMMAND[@]} --name MY_MAP_OF_MAP --type "map_of map" --print -- n k v \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP_OF_MAP]="map_of map" )' \
                'declare -A MY_MAP_OF_MAP=([n]="0" )' \
                'declare -A MY_MAP_OF_MAP_0=([k]="v" )'

        # map_of map_of map
        ${CLI_COMMAND[@]} --name MY_META --type "map_of map_of map" \
            | ${CLI_COMMAND[@]} --source --name MY_META -- default color black \
            | ${CLI_COMMAND[@]} --source --name MY_META -- allow color black \
            | ${CLI_COMMAND[@]} --source --name MY_META --print -- allow color white \
            | sort \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_META]="map_of map_of map" )' \
                'declare -A MY_META=([default]="0" [allow]="1" )' \
                'declare -A MY_META_0=([color]="0" )' \
                'declare -A MY_META_0_0=([black]="" )' \
                'declare -A MY_META_1=([color]="0" )' \
                'declare -A MY_META_1_0=([black]="" [white]="" )'
    }

    user_defined() {

        # map_of udt
        declare -A CLI_TYPE_VERSION=(['major']='integer' ['minor']='integer')
        declare -p CLI_TYPE_VERSION \
            | ${CLI_COMMAND[@]} --source \
                --name MY_MAP_OF_VERSION \
                --type "map_of version" \
                --print \
                -- alpha major 1 \
            | sort \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_MAP_OF_VERSION]="map_of version" )' \
                'declare -A CLI_TYPE_VERSION=([minor]="integer" [major]="integer" )' \
                'declare -A MY_MAP_OF_VERSION=([alpha]="0" )' \
                'declare -i MY_MAP_OF_VERSION_0_MAJOR="1"' \
                'declare -i MY_MAP_OF_VERSION_0_MINOR="0"'

        # defaults
        cli core struct define --name version \
            | cli core struct define-field --name major --type integer \
            | cli core struct define-field --name minor --type integer \
            | cli core struct define --source --name kitchen_sink_type \
            | cli core struct define-field --name version --type version \
            | cli core struct define-field --name integer --type integer \
            | cli core struct define-field --name map --type map \
            | cli core struct define-field --name array --type array \
            | cli core struct define-field --name boolean --type boolean \
            | cli core struct define-field --name string --type string \
            | cli core struct define-field --name map_of_map --type 'map_of map' \
            | ${CLI_COMMAND[@]} --source --name KITCHEN_SINK --type kitchen_sink_type  \
            | ${CLI_COMMAND[@]} --source --name KITCHEN_SINK --print \
            | assert::pipe_eq \
                'declare -A CLI_TYPE_KITCHEN_SINK_TYPE=([boolean]="boolean" [version]="version" [map]="map" [map_of_map]="map_of map" [string]="string" [array]="array" [integer]="integer" )' \
                'declare -A CLI_TYPE_VERSION=([minor]="integer" [major]="integer" )' \
                'declare -A CLI_SCOPE+=([KITCHEN_SINK]="kitchen_sink_type" )' \
                'declare -a KITCHEN_SINK_ARRAY=()' \
                'declare -- KITCHEN_SINK_BOOLEAN="false"' \
                'declare -i KITCHEN_SINK_INTEGER="0"' \
                'declare -A KITCHEN_SINK_MAP=()' \
                'declare -A KITCHEN_SINK_MAP_OF_MAP=()' \
                'declare -- KITCHEN_SINK_STRING=""' \
                'declare -i KITCHEN_SINK_VERSION_MAJOR="0"' \
                'declare -i KITCHEN_SINK_VERSION_MINOR="0"'

        # motiviating scenario -- representation of parameter metadata
        cli core struct define --name my_meta \
            | cli core struct define-field --name timeout --type integer \
            | cli core struct define-field --name require --type map \
            | cli core struct define-field --name default --type map \
            | cli core struct define-field --name alias --type map \
            | cli core struct define-field --name implicit_value --type map \
            | cli core struct define-field --name positional --type boolean \
            | cli core struct define-field --name allow --type 'map_of map' \
            | ${CLI_COMMAND[@]} --source --name MY_META --type my_meta \
            | ${CLI_COMMAND[@]} --source --name MY_META -- timeout 42 \
            | ${CLI_COMMAND[@]} --source --name MY_META -- allow help true \
            | ${CLI_COMMAND[@]} --source --name MY_META -- allow help false \
            | ${CLI_COMMAND[@]} --source --name MY_META -- implicit_value help true \
            | ${CLI_COMMAND[@]} --source --name MY_META -- default help false \
            | ${CLI_COMMAND[@]} --source --name MY_META -- alias h help \
            | ${CLI_COMMAND[@]} --source --name MY_META -- require name \
            | ${CLI_COMMAND[@]} --source --name MY_META -- positional true \
            | ${CLI_COMMAND[@]} --source --name MY_META --print \
            | sort \
            | assert::pipe_eq \
                'declare -- MY_META_POSITIONAL="true"' \
                'declare -A CLI_SCOPE+=([MY_META]="my_meta" )' \
                'declare -A CLI_TYPE_MY_META=([require]="map" [default]="map" [timeout]="integer" [positional]="boolean" [implicit_value]="map" [alias]="map" [allow]="map_of map" )' \
                'declare -A MY_META_ALIAS=([h]="help" )' \
                'declare -A MY_META_ALLOW=([help]="0" )' \
                'declare -A MY_META_ALLOW_0=([false]="" [true]="" )' \
                'declare -A MY_META_DEFAULT=([help]="false" )' \
                'declare -A MY_META_IMPLICIT_VALUE=([help]="true" )' \
                'declare -A MY_META_REQUIRE=([name]="" )' \
                'declare -i MY_META_TIMEOUT="42"'
    }

    redeclare() {

        # array
        ${CLI_COMMAND[@]} --name MY_ARRAY --type array \
            | ${CLI_COMMAND[@]} --source --name MY_ARRAY -- a \
            | ${CLI_COMMAND[@]} --source --name MY_ARRAY --type array --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_ARRAY]="array" )' \
                'declare -a MY_ARRAY=([0]="a")'

        # boolean
        ${CLI_COMMAND[@]} --name MY_BOOLEAN --type boolean \
            | ${CLI_COMMAND[@]} --source --name MY_BOOLEAN -- true \
            | ${CLI_COMMAND[@]} --source --name MY_BOOLEAN --type boolean --print \
            | assert::pipe_eq \
                'declare -A CLI_SCOPE+=([MY_BOOLEAN]="boolean" )' \
                'declare -- MY_BOOLEAN="true"'

        # switch
        assert::pipe_fails << EOF
            ${CLI_COMMAND[@]} --name MY_VAR --type boolean \
                | ${CLI_COMMAND[@]} --source --name MY_VAR --type boolean \
                | ${CLI_COMMAND[@]} --source --name MY_VAR --type integer
EOF
    }

    read_records
    builtin_default
    builtin_assign
    redeclare
    user_defined
)
