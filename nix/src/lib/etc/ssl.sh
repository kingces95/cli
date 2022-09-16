alias ssl-hex="nix::ssl::hex"

nix::ssl::hex() {
    local COUNT="${1-2}"
    openssl rand -hex "${COUNT}"
}

nix::ssl::digest() {
    read _ REPLY < <(openssl dgst -sha256)
    echo "${REPLY}"
}