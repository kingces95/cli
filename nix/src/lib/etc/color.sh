nix::color::begin() {
    local CODE="$1"
    shift

    echo "\e[${CODE}m"
}

nix::color::end() {
    echo "\e[0m"
}

nix::color() {
    local CODE="$1"
    shift

    local BEGIN="$(nix::color::begin "${CODE}")"
    local END="$(nix::color::end)"

    echo "${BEGIN}$*${END}"
}

nix::color::red() { nix::color "${NIX_COLOR_RED}" "$@"; }
nix::color::yellow() { nix::color "${NIX_COLOR_YELLOW}" "$@"; }
nix::color::cyan() { nix::color "${NIX_COLOR_CYAN}" "$@"; }
nix::color::green() { nix::color "${NIX_COLOR_GREEN}" "$@"; }

nix::color::begin::red() { nix::color::begin "${NIX_COLOR_RED}"; }
nix::color::begin::yellow() { nix::color::begin "${NIX_COLOR_YELLOW}"; }
nix::color::begin::cyan() { nix::color::begin "${NIX_COLOR_CYAN}"; }
nix::color::begin::green() { nix::color::begin "${NIX_COLOR_GREEN}"; }

