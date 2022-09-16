nix::bash::emit::continue_line() {
    read
    printf '%s' "${REPLY}"

    while read; do
        printf $' \\\n%s' "${REPLY}"
    done

    echo
}

nix::bash::emit::indent() {
    sed 's/^/    /'
}

nix::bash::emit::subproc() {
    echo '('
    nix::bash::emit::indent
    echo ')'
}

nix::bash::emit::alias() {
    local NAME="$1"
    shift

    local VALUE="$1"
    shift

    echo "alias ${NAME}=\"${VALUE}\""
}
