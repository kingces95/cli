nix::log::printf() {
    local FORMAT="$1"
    shift

    printf "$(nix::color::cyan "${FORMAT}")" "$@"
}

nix::log::error::printf() {
    local FORMAT="$1"
    shift

    printf "$(nix::color::red "${FORMAT}")" "$@"
}

nix::log::prompt() {
    printf "$(nix::color::begin::yellow)"
    printf '%s' "$*"
    printf "$(nix::color::end)"
    read
}

nix::log::color_reset() {
    echo -e -n "\033[0m"
}

nix::log::begin() {
    nix::log::printf '%s' "$* "
}

nix::log::end() {
    printf "%s$(nix::color::end)\n" "$@"
}

nix::log::echo() {
    nix::log::begin "$*"
    nix::log::end
}

nix::log::subproc::begin() {
    
    local LOG=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.log")
    local ERR=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.err")

    if [[ "$@" ]]; then
        nix::log::begin "$@ (logs: ${LOG} ${ERR})" >&2
        trap "exec 1>&3; exec 2>&4; nix::log::subproc::end ${ERR} >&2" EXIT 
    fi

    exec 3>&1
    exec 4>&2
    exec 1>"${LOG}"
    exec 2>"${ERR}"
}

nix::log::subproc::end() {
    local ERR="$1"

    if [[ -s "${ERR}" ]]; then
        nix::log::error::printf "!"
    fi

    nix::log::end
}
