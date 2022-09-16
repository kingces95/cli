# Test Gmail, GitHub, and Azure Accounts
Shared gmail, github, and azure accounts emulate a virtual developer. Github Personal Access tokens are needed during `CatalogItem` testing to access a repository hosting the catalog items. Azure guest accounts are needed during GitHub Actions CI.

## Gmail Account
The shared gmail account is fidalgo.test@gmail.com. 
- The password is the shared team password. 
- MFA is disabled.

## Azure Account
The gmail account has an Azure Account. 
- The password is the shared team password.
- The account is a guest in our testing environments.
   - `fidalgoppe010.onmicrosoft.com`
   - `testcpcselfhostdevdiv.onmicrosoft.com`
   - `fidalgobeta.onmicrosoft.com`
   - `fidalgosh010.onmicrosoft.com`
 - The account is a member of the `Admin` and `MFA Excluded Users` groups. 

## GitHub Account
The GitHub account is **fidalgotesting** and is owned my the gmail account. 

## GitHub Projects
- [Azure/fidalgo-dev](https://github.com/Azure/fidalgo-dev) hosts NIX. 
  - The GitHub account is an [Outside Collaborator](https://github.com/Azure/fidalgo-dev/settings/access?query=filter%3Aoutside_collaborators) with `Write` access.
- [Azure/fidalgoIntegrationTests](https://github.com/Azure/fidalgoIntegrationTests/settings/access?query=filter%3Aoutside_collaborators) hosts catalog items. 
  - The GitHub account is an [Outside Collaborator](https://github.com/Azure/fidalgoIntegrationTests/settings/access?query=filter%3Aoutside_collaborators) with `Read` access.

## Docker Account
The codespace prebuild image is stored in [hub.docker.com](https://hub.docker.com/). 
- Account name is `fidalgotesting`
- Account password is the shared team password.

## Relay
Dogfood is not publicly accessible; Developers need to to VPN to access dogfood. In a Codespace VPN is not available. Instead, Azure Relay can be used to access dogfood. 

The tool [azbridge](https://github.com/Azure/azure-relay-bridge) uses Azure Relay to create a reverse proxy. The reverse proxy relays requests made to dogfood from within a codespace to a corp connected server which then forwards them to dogfood.

- [kingces95/azure-relay-bridge-binaries](https://github.com/kingces95/azure-relay-bridge-binaries) - azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb
- [Azure Relay](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/dev/providers/Microsoft.Relay/namespaces/fidalgo/overview) - https://fidalgo.servicebus.windows.net
  - Endpoint: `sb://fidalgo.servicebus.windows.net/`
  - SharedAccessKeyName: `RootManageSharedAccessKey`
  - Hybrid Connection: [`dogfood`](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/dev/providers/Microsoft.Relay/namespaces/fidalgo/HybridConnections/dogfood/overview)

# KeyVault
The account's secrets are stored in [nix-kv](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/nix/providers/Microsoft.KeyVault/vaults/nix-kv/overview) [secrets](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/nix/providers/Microsoft.KeyVault/vaults/nix-kv/secrets).
  - `azure-password`: Shared team password.
  - `azure-relay-shared-access-key`: Shared access key for the Azure relay.
  - `github-password`: Password.
    - The password is the shared team password with `0` appended. 
  - `github-mfa-code`: Multi Factor Authentication Code.
    - Manually enter into Authenticator to generate actual login codes.
  - `github-recovery-codes`: Account recovery codes.
  - `github-pag`: [Personal Access Token](https://github.com/settings/tokens) with no options selected.
  - `github-pat-repo-scope`: [Personal Access Token](https://github.com/settings/tokens) with `repo scope` options selected.
    - Use when repo hosting catalog items is private.