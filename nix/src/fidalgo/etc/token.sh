alias fd-token="nix::az::account::get_access_token"
alias fd-token-dataplane="nix::env::token::dataplane"

nix::env::token::dataplane() {
    nix::az::account::get_access_token "${NIX_FIDALGO_DATAPLANE_TOKEN_URL}"
}
