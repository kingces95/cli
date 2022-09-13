#!/usr/bin/env CLI_TOOL=cli bash-cli-part
CLI_IMPORT=(
    "cli bash yield"
)

cli::bash::map::keys::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Copy sorted map keys to stdout.

Description
    Argument \$1 is the name of the map.
EOF
}

cli::bash::map::keys() {
    local -n MAP_REF=${1?'Missing map.'}

    cli::bash::yield "${!MAP_REF[@]}" | sort
}

cli::bash::map::keys::self_test() {
    local -A MAP=( [a]=0 [b]=1 [c]=2 )
    diff <(${CLI_COMMAND[@]} -- MAP) - <<< $'a\nb\nc' || cli::assert
}
