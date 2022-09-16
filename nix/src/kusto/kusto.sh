alias kusto-www="nix::shell::browser::open https://dataexplorer.azure.com/"
alias kusto-code-install="nix::code::reinstall ${NIX_KUSTO_VSCODE_SYNTAX_HIGHLIGHTING}"

nix::kusto::spy() {
    nix::spy NIX_KUSTO_SPY "$@"
}

nix::kusto::execute() {
    nix::kusto::pipeline::main \
        "" \
        "$@" 
}

nix::kusto::execute::raw() {
    nix::kusto::pipeline::main \
        'nix::kusto::pipeline::execute' \
        "$@" 
}

nix::kusto::query() {
    nix::kusto::pipeline::main \
        nix::kusto::pipeline::query::substitute \
        "$@" 
}

nix::kusto::debug() {
    # DEBUGGING AIDS
    # az login --use-device-code
    # dotnet ${NIX_KUSTO_DLL} "$(nix::kusto::connection_string)"
    # az account get-access-token --resource https://help.kusto.windows.net --query accessToken --output tsv
    # #connect Data Source=https://devceneterpublic.westus2.kusto.windows.net/;Fed=true;Initial Catalog=devcenter-public;UserToken=
    # customMetrics | where Name contains "Certificate.Loaded.Count" | where timestamp_utc > ago(1h)
    
    dotnet ${NIX_KUSTO_DLL} "$@"   
    nix::kusto::launch "$(nix::kusto::connection_string)" "$@"
}
