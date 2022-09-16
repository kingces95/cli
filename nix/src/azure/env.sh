alias az-env-output="nix::azure::env::output::export"
alias az-env-output-on="nix::azure::env::output::export json"
alias az-env-output-off="nix::azure::env::output::export none"

# https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration#cli-configuration-file
# https://github.com/Azure/azure-cli/issues/17989

nix::azure::env::use_dynamic_install::export() {
    export AZURE_EXTENSION_USE_DYNAMIC_INSTALL="$@"
}

nix::azure::env::run_after_dynamic_install::export() {
    export AZURE_EXTENSION_RUN_AFTER_DYNAMIC_INSTALL="$@"
}

nix::azure::env::only_show_errors::export() {
    export AZURE_CORE_ONLY_SHOW_ERRORS="$@"
}

nix::azure::env::output::export() {
    export AZURE_CORE_OUTPUT="${1-json}"
}

nix::azure::env::disable_confirm_prompt::export() {
    export AZURE_DISABLE_CONFIRM_PROMPT="$@"
}

nix::azure::env::config_dir::export() {
    export AZURE_CONFIG_DIR="$@"
}

nix::azure::env::cloud::export() {
    export AZURE_CLOUD_NAME="$@"
}

nix::azure::env::defaults::group::export() {
    export AZURE_DEFAULTS_GROUP="$@"
}

nix::azure::env::defaults::location::export() {
    export AZURE_DEFAULTS_LOCATION="$@"
}
