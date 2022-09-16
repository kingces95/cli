alias vpt-azure-relay-create='nix::azure::relay::create'
alias vpt-azure-relay-delete='nix::azure::relay::delete'
alias vpt-azure-relay-show='nix::azure::relay::show'
alias vpt-azure-relay-test='nix::azure::relay::test'
alias vpt-azure-relay-connection-string='nix::azure::relay::connection_string'
alias vpt-azure-relay-www='nix::azure::relay::www'

nix::az() (
    export AZURE_DISABLE_CONFIRM_PROMPT=yes
    export AZURE_DEFAULTS_GROUP="${VPT_AZURE_GROUP}"
    export AZURE_DEFAULTS_LOCATION="${VPT_AZURE_LOCATION}"
    
    az "$@"
)

nix::azure::relay::show() {
    nix::az relay hyco show \
        --name "${VPT_AZURE_RELAY_NAME}" \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}"
}

nix::azure::relay::test() {
    nix::azure::relay::show \
        >/dev/null 2>&1
}

nix::azure::relay::create() (
    if nix::azure::relay::test; then
        return
    fi

    nix::az group create \
        --name "${VPT_AZURE_GROUP}" \
        --location "${AZURE_DEFAULTS_LOCATION}"

    nix::az relay namespace create \
        --name "${VPT_AZURE_RELAY_NAMESPACE}"

    nix::az relay hyco create \
        --name "${VPT_AZURE_RELAY_NAME}" \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}" \
        --requires-client-authorization true
)

nix::azure::relay::delete() {
    if ! nix::azure::relay::test; then
        return
    fi

    nix::az relay namespace delete \
        --name "${VPT_AZURE_RELAY_NAMESPACE}"
}

nix::azure::relay::connection_string() {
    nix::azure::relay::create \
        >/dev/null

    nix::az relay namespace authorization-rule keys list \
        --name 'RootManageSharedAccessKey' \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}" \
        --query primaryConnectionString \
        --output tsv
}

nix::azure::relay::www() {
    nix::azure::relay::create

    local URL=(
        'https://ms.portal.azure.com/'
        '#@microsoft.onmicrosoft.com/resource'
        "/subscriptions/${VPT_AZURE_SUBSCRIPTION}"
        "/resourceGroups/${VPT_AZURE_GROUP}"
        "/providers/Microsoft.Relay/namespaces/${VPT_AZURE_RELAY_NAMESPACE}/hybridConnections"
        "/${VPT_AZURE_RELAY_NAME}/overview"
    )
    (
        IFS=
        echo "${URL[*]}"
    )
}
