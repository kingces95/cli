alias fd-cli-install="nix::env::cli::install"
alias fd-cli-uninstall="nix::env::cli::uninstall"

nix::env::cli::install() {
    nix::cli::install "${NIX_ENV_CLI_VERSION}"
}
