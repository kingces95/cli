
CLI_IMPORT=(
    "cli import lib-y"
    "cli import inline-a"
)

cli::import::lib_x::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Test.
EOF
}

cli::import::lib_x::main() {

    declare -f cli::import::inline_a >&2
    declare -f lib_y::foo >&2
    declare -f lib_y::bar >&2

    LIB_X_VAR=42
    lib_x::foo() {
        echo "function=lib_x::foo"
    }
    declare -p LIB_X_VAR
    declare -f lib_x::foo
}

