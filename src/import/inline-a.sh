
CLI_IMPORT=(
    "cli import inline-b0"
    "cli import inline-b1"
)

cli::import::inline_a() {
    echo "function=inline-a"
    declare -f cli::import::inline_b0
    declare -f cli::import::inline_b1
}
