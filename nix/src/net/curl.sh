alias fd-curl='nix::curl'

nix::curl() {
    local URL="$1"
    shift

    curl -fsSL "${URL}"
}
