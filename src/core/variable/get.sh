#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable resolve
cli::source cli core type get-info

help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Get a scaler, array element, or map value for a path.

Description
    Argument \$1-n is the type of the variable $n+1. The remaining positional
    arguments are the path to the builtin type. If the builtin type is an
    array then ARG_INDEX must contain the element to return. If the builtin
    is a map then ARG_KEY must contain the key of the value to return. If the
    key does not exist then the function fails.

    The value is returned in REPLY.
EOF
}

cli::core::variable::get::main() {
    ::cli::core::variable::get::inline "$@"
    echo "${REPLY}"
}

::cli::core::variable::get::inline() {
    ::cli::core::variable::resolve::inline "$@"
    local NAME="${REPLY}"

    ::cli::core::variable::get_info::inline "${NAME}"
    local TYPE="${REPLY}"

    ${REPLY_CLI_CORE_TYPE_IS_BUILTIN} \
        || cli::assert "Expected to resolve '$@' to bultin type but got a type '${TYPE}'."

    case "${TYPE}" in
        'string') ;&
        'boolean') ;&
        'integer') 
            REPLY="${!NAME}" ;;

        'array')
            local -n REF="${NAME}"
            REPLY="${REF[${ARG_INDEX}]}" ;;

        'map')
            local -n REF="${NAME}"
            if [[ ! ${REF[${ARG_KEY}]+set} == 'set' ]]; then
                REPLY=
                return 1
            fi
            REPLY="${REF[${ARG_KEY}]}" ;;

        *) cli::assert "Expected builtin type but got '${TYPE}'."
    esac
}

cli::core::variable::get::self_test() (
    local -A SCOPE=()
    local ARG_SCOPE='SCOPE'

    # builtin
    local -A SCOPE=(
        ['MY_STRING']='string'
        ['MY_INTEGER']='integer'
        ['MY_BOOLEAN']='boolean'
        ['MY_MAP']='map'
        ['MY_ARRAY']='array'
    )

    # string
    local MY_STRING='Hello World!'
    diff <(${CLI_COMMAND[@]} -- MY_STRING) - <<< 'Hello World!'

    # integer
    local -i MY_INTEGER=42
    diff <(${CLI_COMMAND[@]} -- MY_INTEGER) - <<< '42'

    # boolean
    local MY_BOOLEAN=true
    diff <(${CLI_COMMAND[@]} -- MY_BOOLEAN) - <<< 'true'

    # array
    local -a MY_ARRAY=( a a b a )
    diff <(ARG_INDEX=0 ${CLI_COMMAND[@]} -- MY_ARRAY) - <<< 'a'

    # array
    local -a MY_ARRAY=( a a b a )
    diff <(ARG_INDEX=2 ${CLI_COMMAND[@]} -- MY_ARRAY) - <<< 'b'

    # array
    local -a MY_ARRAY=( 'a a b a' )
    diff <(ARG_INDEX=0 ${CLI_COMMAND[@]} -- MY_ARRAY) - <<< 'a a b a'

    # map
    local -A MY_MAP=( [key]=value [element]= )
    diff <(ARG_KEY='key' ${CLI_COMMAND[@]} -- MY_MAP) - <<< 'value'
    ! ARG_KEY='no such key' ${CLI_COMMAND[@]} -- MY_MAP >/dev/null
    ARG_KEY='element' ${CLI_COMMAND[@]} -- MY_MAP >/dev/null

    # map_of map
    local -A SCOPE=(
        ['MOD_MAP']='map_of map'
        ['MOD_MAP_0']='map'
    )

    local -A MOD_MAP=(
        ['seq']=0
    )
    local -A MOD_MAP_0=(
        ['pi']=3141
        ['fib']=11235
    )
    diff <(ARG_KEY=fib ${CLI_COMMAND[@]} -- MOD_MAP seq) - <<< '11235'
    diff <(ARG_KEY=pi ${CLI_COMMAND[@]} -- MOD_MAP seq) - <<< '3141'
    
    # map_of map_of integer
    local -A SCOPE=(
        ['MOD_MOD_INTEGER']='map_of map_of integer'
        ['MOD_MOD_INTEGER_0']='map_of integer'
        ['MOD_MOD_INTEGER_0_0']='integer'
        ['MOD_MOD_INTEGER_0_1']='integer'
    )

    local -A MOD_MOD_INTEGER=(
        ['seq']=0
    )
    local -A MOD_MOD_INTEGER_0=(
        ['fib']=0
        ['pi']=1
    )
    local -A MOD_MOD_INTEGER_0_0=11235
    local -A MOD_MOD_INTEGER_0_1=3141
    diff <(${CLI_COMMAND[@]} -- MOD_MOD_INTEGER seq fib) - <<< '11235'
    diff <(${CLI_COMMAND[@]} -- MOD_MOD_INTEGER seq pi) - <<< '3141'

    # map_of array
    local -A SCOPE=(
        ['MOD_ARRAY']='map_of array'
        ['MOD_ARRAY_0']='array'
    )

    local -A MOD_ARRAY=(
        ['seq']=0
    )
    local -a MOD_ARRAY_0=( 'fib' 'pi' )
    diff <(ARG_INDEX=0 ${CLI_COMMAND[@]} -- MOD_ARRAY seq) - <<< 'fib'
    diff <(ARG_INDEX=1 ${CLI_COMMAND[@]} -- MOD_ARRAY seq) - <<< 'pi'

    # udt
    local -A SCOPE=(
        ['MY_VERSION']='version'
        ['MY_VERSION_MAJOR']='integer'
        ['MY_VERSION_MINOR']='integer'
    )

    local -A CLI_TYPE_VERSION=(
        ['major']=integer
        ['minor']=integer
    )
    local MY_VERSION_MAJOR=1
    local MY_VERSION_MINOR=2
    diff <(${CLI_COMMAND[@]} -- MY_VERSION major) - <<< '1'
    diff <(${CLI_COMMAND[@]} -- MY_VERSION minor) - <<< '2'

    # udt
    local -A SCOPE=(
        ['META']='metadata'
        ['META_POSITIONAL']='boolean'
        ['META_VERSION']='version'
        ['META_VERSION_MAJOR']='integer'
        ['META_VERSION_MINOR']='integer'
        ['META_ALLOW']='map_of map'
        ['META_ALLOW_0']='map'
        ['META_MMM']='map_of map_of map'
        ['META_MMM_0']='map_of map'
        ['META_MMM_0_0']='map'
    )

    local -A CLI_TYPE_METADATA=(
        ['allow']='map_of map'
        ['mmm']='map_of map_of map'
        ['positional']='boolean'
        ['version']='version'
    )

    local META_POSITIONAL=true
    local -i META_VERSION_MAJOR=1
    local -i META_VERSION_MINOR=2
    local -A META_ALLOW=(
        ['color']=0
    )
    local -A META_ALLOW_0=(
        ['black']=
        ['white']=
    )
    local -A META_MMM=(
        ['a']=0
    )
    local -A META_MMM_0=(
        ['b']=0
    )
    local -A META_MMM_0_0=(
        ['c']='d'
    )

    diff <(ARG_KEY='white' ${CLI_COMMAND[@]} -- META allow color) - <<< ''
    diff <(ARG_KEY='black' ${CLI_COMMAND[@]} -- META allow color) - <<< ''
    diff <(ARG_KEY='c' ${CLI_COMMAND[@]} -- META mmm a b) - <<< 'd'
    diff <(${CLI_COMMAND[@]} -- META positional) - <<< 'true'
    diff <(${CLI_COMMAND[@]} -- META version major) - <<< '1'
    diff <(${CLI_COMMAND[@]} -- META version minor) - <<< '2'
)
