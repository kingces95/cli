# shim (see /etc/profile.d/nix.sh )
# readonly NIX_EXIT_REMAIN=101
# readonly NIX_ROOT_DIR="/workspaces"
# readonly NIX_REPO_DIR="${NIX_ROOT_DIR}/fidalgo-dev"
# readonly NIX_DIR="${NIX_REPO_DIR}/nix"
# readonly NIX_LOADER="${NIX_DIR}/loader.sh"
# readonly NIX_DIR_NIX_USR="${NIX_DIR}/usr"
# readonly NIX_DIR_NIX_SRC="${NIX_DIR}/src"

# azure config
export AZURE_EXTENSION_USE_DYNAMIC_INSTALL=yes_without_prompt
export AZURE_EXTENSION_RUN_AFTER_DYNAMIC_INSTALL=True

# bash
readonly NIX_INTEGER_MAX=10000000

# colors
readonly NIX_COLOR_RED='0;31'
readonly NIX_COLOR_GREEN='0;32'
readonly NIX_COLOR_YELLOW='0;33'
readonly NIX_COLOR_CYAN='0;36'

# exit codes
readonly NIX_EXIT_RELOAD=100
readonly NIX_EXIT_CHROOT_REINITIALIZE=102
readonly NIX_EXIT_CHROOT_REMOVE=103

# user
readonly NIX_USER="${USER}"
readonly NIX_BASH_LOGIN="${HOME}/.bash_login"
readonly NIX_BASH_PROFILE="${HOME}/.bash_profile"

# debootstrap
readonly NIX_UBUNTU_CODENAME='focal'

# personal
readonly NIX_GITHUB_USER_RECORDS="${NIX_DIR_NIX_USR}/github-user"
readonly NIX_IP_ALLOCATION_RECORDS="${NIX_DIR_NIX_USR}/ip-allocation"
readonly NIX_HOME="${NIX_DIR_NIX_USR}/${NIX_USER}"
readonly NIX_PROFILE="${NIX_HOME}/profile.sh"

# directories
readonly NIX_DIR_NIX_SSH="${NIX_DIR}/ssh"
readonly NIX_DIR_NIX_TST="${NIX_DIR}/tst"
readonly NIX_DIR_NIX_TST_SRC="${NIX_DIR_NIX_TST}/src"
readonly NIX_DIR_NIX_TST_SRC_RESOURCE="${NIX_DIR_NIX_TST_SRC}/resource"
readonly NIX_DIR_NIX_TST_SH="${NIX_DIR_NIX_TST}/sh"
readonly NIX_DIR_NIX_TST_BUG="${NIX_DIR_NIX_TST}/bug"
readonly NIX_DIR_NIX_TST_ENV="${NIX_DIR_NIX_TST}/env"

# repo directories
readonly NIX_REPO_DIR_SRC="${NIX_REPO_DIR}/src"
readonly NIX_REPO_DIR_KUSTO="${NIX_REPO_DIR}/kusto"
readonly NIX_REPO_DIR_AZ="${NIX_REPO_DIR}/az"

# os directories
readonly NIX_OS_DIR_TEMP='/tmp'
readonly NIX_OS_DIR_ETC='/etc'
readonly NIX_OS_DIR_APT="${NIX_OS_DIR_ETC}/apt"

# wsl
readonly NIX_OS_WSL_CONF="${NIX_OS_DIR_ETC}/wsl.conf"

# home directories
readonly NIX_HOME_DIR_SSH="${HOME}/.ssh"
readonly NIX_HOME_SUDO_HUSH="${HOME}/.sudo_as_admin_successful"

# apt
readonly NIX_OS_APT_DIR_LISTS='/var/lib/apt/lists'
readonly NIX_OS_APT_DIR_TRUSTED="${NIX_OS_DIR_APT}/trusted.gpg.d"
readonly NIX_OS_APT_DIR_SOURCES="${NIX_OS_DIR_APT}/sources.list.d"
readonly NIX_OS_APT_SOURCES_LIST="${NIX_OS_DIR_APT}/sources.list"
readonly NIX_OS_APT_CONFIG_HASH="${NIX_OS_DIR_APT}/config.hash"
readonly NIX_OS_APT_PACKAGE_TIMESTAMP="${NIX_OS_DIR_ETC}/apt-last-updated"
readonly NIX_OS_APT_LAST_UPDATE_TIMEOUT=30

# ssh
readonly NIX_OS_SSH_KNOWN_HOSTS="${NIX_HOME_DIR_SSH}/known_hosts"
readonly NIX_SSH_KNOWN_HOST="${NIX_DIR_NIX_SSH}/known_hosts"

# source control
readonly NIX_AZURE_DEV_SSH_HOST='ssh.dev.azure.com'
readonly NIX_AZURE_DEV_SSH_KNOWN_HOST="${NIX_DIR_NIX_SSH}/${NIX_AZURE_DEV_SSH_HOST}"
readonly NIX_AZURE_DEV_SSH_WWW='https://dev.azure.com/devdiv/_usersSettings/keys'

# tool
readonly NIX_OS_APT_TOOLS="${NIX_DIR}/.tools"

# pgp
readonly NIX_PGP_URL_GITHUB=https://cli.github.com/packages/githubcli-archive-keyring.gpg
readonly NIX_PGP_URL_MICROSOFT=https://packages.microsoft.com/keys/microsoft.asc

# tool (apt)
readonly NIX_TOOL_APT_FIELD_PACKAGE=3
readonly NIX_TOOL_APT_FIELD_VERSION=4
readonly NIX_TOOL_APT_FIELD_REPOSITORY=5
readonly NIX_TOOL_APT_FIELD_DISTRO=6
readonly NIX_TOOL_APT_FIELD_URL=7
readonly NIX_TOOL_APT_FIELD_KEY=8

# tool (deb)
readonly NIX_TOOL_DEB_FIELD_PACKAGE=3
readonly NIX_TOOL_DEB_FIELD_URL=4

# tool (nuget)
readonly NIX_TOOL_NUGET_DIR="${NIX_OS_DIR_TEMP}/nuget"
readonly NIX_TOOL_NUGET_FIELD_PACKAGE=3
readonly NIX_TOOL_NUGET_FIELD_VERSION=4
readonly NIX_TOOL_NUGET_FIELD_FRAMEWORK=5

# azure conig
readonly NIX_AZURE_DIR="${NIX_REPO_DIR}/.azure"
readonly NIX_AZURE_PID_DIR="${NIX_AZURE_DIR}/${NIX}"
readonly NIX_AZURE_TOKEN_CACHE_FILE='msal_token_cache.json'
readonly NIX_AZURE_PROFILE_FILE='azureProfile.json'
readonly NIX_AZURE_TOKEN_CACHE="${NIX_AZURE_DIR}/${NIX_AZURE_TOKEN_CACHE_FILE}"

# CPC bugs
readonly NIX_WWW_CPC_BUG_INTEGRATION="https://aka.ms/devdivcpcintegrationbug"
readonly NIX_WWW_CPC_BUG="https://aka.ms/devdivcpcbug"
readonly NIX_WWW_CPC_FEATURE="https://aka.ms/fidalgow365featurerequest"

# dependencies
readonly NIX_DEPENDENCY_DEB=(
    https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
)

readonly NIX_TOOL_EAGERLY_INSTALL=(
    gpg
    curl
)
readonly NIX_DEPENDENCY_APT=(
    apt-transport-https 
    lsb-release 
    gnupg 
    curl
    nuget
    jq
    dotnet-runtime-5.0
    colordiff
)

# global
readonly NIX_UPN_MICROSOFT="${NIX_USER}@microsoft.com"

# kusto (type inference)
readonly -A NIX_KUSTO_TYPE_REGEX=(
    ['^"']='string'
    ['^true$']='boolean'
    ['^false$']='boolean'
    ['^[[:digit:]]+$']='long'
    ['^[[:digit:]]+[.][[:digit:]]+$']='real'
    ['^ago']='datetime'
    ['^[[:digit:]]+[wdhms]']='timespan'
)

# bookmarks
readonly NIX_WWW_OPTIONAL_CLAIMS=https://identitydocs.azurewebsites.net/static/v2/active-directory-optional-claims.html
readonly NIX_WWW_TOKEN_PARSER=https://jwt.io/
readonly NIX_WWW_SPECS=https://microsoft.sharepoint.com/teams/Fidalgo/Shared%20Documents
readonly NIX_WWW_GENEVA_ACTIONS=https://dev.azure.com/devdiv/OnlineServices/_wiki/wikis/OnlineServices.wiki/27512/Geneva-Actions

# kusto binary
readonly NIX_KUSTO_DIR="${NIX_TOOL_NUGET_DIR}/kusto"
readonly NIX_KUSTO_DLL="${NIX_KUSTO_DIR}/Microsoft.Azure.Kusto.Tools.6.0.1/tools/net5.0/Kusto.Cli.dll"

# kusto bookmarks
readonly NIX_KUSTO_WWW_AUTH_FLOW=https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/access-control/how-to-authenticate-with-aad

# kusto connection
readonly NIX_KUSTO_TOKEN_URL=https://help.kusto.windows.net

# kusto public
readonly NIX_KUSTO_PUBLIC_CLUSTER=devcenterpublic.westus3
readonly NIX_KUSTO_PUBLIC_DATA_SOURCE=https://devcenterpublic.westus3.kusto.windows.net/
readonly NIX_KUSTO_PUBLIC_INITIAL_CATALOG=devcenter-public

# kusto dogfood
readonly NIX_KUSTO_DOGFOOD_CLUSTER=devcenterdogfood.westus3
readonly NIX_KUSTO_DOGFOOD_DATA_SOURCE=https://devcenterdogfood.westus3.kusto.windows.net
readonly NIX_KUSTO_DOGFOOD_INITIAL_CATALOG=devcenter-dogfood

# kusto queries
readonly NIX_KUSTO_QUERY_DIR="${NIX_REPO_DIR_KUSTO}"

# kusto (query editing)
readonly NIX_KUSTO_VSCODE_SYNTAX_HIGHLIGHTING='rosshamish.kuskus-kusto-syntax-highlighting'

# http
readonly NIX_HTTP_DATAPLANE="${NIX_REPO_DIR}/http/dataplane"

# catalog
readonly NIX_GITHUB_CATALOG_URL=https://github.com/Azure/fidalgoIntegrationTests.git
readonly NIX_GITHUB_CATALOG_BRANCH=main
readonly NIX_GITHUB_CATALOG_PATH=/CatalogTests/ValidSingleTemplate
readonly NIX_GITHUB_ACCOUNT=fidalgo.testing@gmail.com

# keyvault
readonly NIX_KEYVAULT='nix-ppe-kv'
readonly NIX_KEYVAULT_SECRET_AZURE_PASSWORD='azure-password'
readonly NIX_KEYVAULT_SECRET_AZURE_RELAY_SHARED_ACCESS_KEY='azure-relay-shared-access-key'
readonly NIX_KEYVAULT_SECRET_GITHUB_RECOVERY_CODES='github-recovery-codes'
readonly NIX_KEYVAULT_SECRET_GITHUB_PAT='github-pat'
readonly NIX_KEYVAULT_SECRET_GITHUB_PAT_REPO_SCOPE='github-pat-repo-scope'
readonly NIX_KEYVAULT_SECRET_GITHUB_PASSWORD='github-password'
readonly NIX_KEYVAULT_SECRET_GITHUB_MFA_CODE='github-mfa-code'

# resource (azure)
readonly -A NIX_AZURE_RESOURCE=(
    ['group']='group'
    ['keyvault']='keyvault'
    ['vnet']='network vnet'
    ['subnet']='network vnet subnet'
    ['secret']='keyvault secret'

    ['devbox-definition']='devcenter admin devbox-definition'
    ['dev-center']='devcenter admin dev-center'
    ['gallery']='devcenter admin gallery'
    ['machine-definition']='devcenter admin machine-definition'
    ['network-setting']='devcenter admin network-setting'
    ['pool']='devcenter admin pool'
    ['project']='devcenter admin project'
    ['virtual-machine']='devcenter dev virtual-machine'
    ['attached-network']='devcenter admin attached-network'
    ['catalog']='devcenter admin catalog'
    ['environment-type']='devcenter admin environment-type'
    ['mapping']='devcenter admin mapping'
    ['environment']='devcenter admin environment'
)
readonly -A NIX_AZURE_RESOURCE_PROVIDER=(
    ['vnet']='Microsoft.Network/virtualNetworks'
    ['keyvault']='Microsoft.KeyVault/vaults'

    ['network-setting']='Microsoft.Devcenter/networksettings'
    ['gallery']='Microsoft.Devcenter/gallery'
    ['dev-center']='Microsoft.Devcenter/devcenters'
    ['project']='Microsoft.Devcenter/projects'
    ['machine-definition']='Microsoft.Devcenter/machinedefinitions'
    ['devbox-definition']='Microsoft.Devcenter/devboxdefinitions'

    ['pool']='pools'
    ['virtual-machine']='virtualmachine'
    ['subnet']='subnets'
    ['attached-network']='attachednetworks'
    ['catalog']='catalogs'
    ['environment-type']='environmenttypes'
    ['mapping']='mappings'
    ['environment']='environments'
)
readonly -A NIX_AZURE_RESOURCE_PARENT=(
    ['gallery']='dev-center'
    ['pool']='project'
    ['virtual-machine']='project'
    ['subnet']='vnet'
    ['attached-network']='dev-center'
    ['catalog']='dev-center'
    ['environment-type']='dev-center'
    ['mapping']='dev-center'
    ['environment']='project'
)
readonly -A NIX_AZURE_RESOURCE_POINTS_TO=(
    # parent-name added by default
    ['virtual-machine']='dev-center pool-name'
    ['project']='dev-center-id'
    ['pool']='devbox-definition-name attached-network-name'
    ['attached-network']='network-setting-id'
    ['network-setting']='subnet-id'
    ['devbox-definition']='dev-center-name'
    ['mapping']='project-id environment-type-name' # BUGBUG: actually environment-type
    ['environment']='environment-type-name' # BUGBUG: actually environment-type
)
readonly -A NIX_AZURE_RESOURCE_ACTIVATION_POSET=(
    ['vnet']=''
    ['subnet']='vnet'
    ['dev-center']='subnet'
    ['keyvault']='dev-center'
    ['gallery']='dev-center'
    ['machine-definition']='subnet'
    ['devbox-definition']='subnet'
    ['project']='dev-center'
    ['mapping']='dev-center project environment-type'
    ['catalog']='dev-center keyvault'
    ['environment-type']='dev-center'
    ['environment']='project environment-type mapping'
    ['network-setting']='subnet'
    ['attached-network']='dev-center network-setting'
    ['pool']='project devbox-definition machine-definition attached-network'
    ['virtual-machine']='dev-center project pool'
)
readonly -A NIX_AZURE_RESOURCE_NO_RESOURCE_GROUP=(
    ['virtual-machine']=true
)
readonly -A NIX_AZURE_RESOURCE_PERSONA=(
    ['vnet']='network-administrator'
    ['subnet']='network-administrator'
    ['keyvault']='administrator'
    ['dev-center']='administrator'
    ['environment-type']='administrator'
    ['environment']='administrator'
    ['mapping']='administrator'
    ['catalog']='administrator'
    ['gallery']='administrator'
    ['machine-definition']='administrator'
    ['devbox-definition']='administrator'
    ['project']='administrator'
    ['network-setting']='administrator'
    ['attached-network']='administrator'
    ['pool']='administrator'
    ['virtual-machine']='developer'
)
readonly -A NIX_AZURE_CPC_RESOURCE=(
    ['vnet']=true
    ['subnet']=true
)

# cert
readonly NIX_CERT_WWW=https://dev.azure.com/devdiv/OnlineServices/_wiki/wikis/OnlineServices.wiki/27763/Certificate-Rotation
readonly NIX_CERT_ICM=https://portal.microsofticm.com/imp/v3/incidents/search/advanced?sl=mykzxnwjxrz
readonly NIX_CERT_OPT_CLAIMS=https://identitydocs.azurewebsites.net/static/v2/active-directory-optional-claims.html

# api
readonly NIX_API_VSCODE_PLUGIN_VISUALIZER=42Crunch.vscode-openapi
readonly NIX_API_VERSION=(
    2022-12-31-privatepreview
    2022-03-01-privatepreview
    2021-12-01-privatepreview
    2021-08-01-privatepreview
)

# az cli
readonly NIX_CLI_WWW=https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/21260/Az-Cli
readonly NIX_CLI_CURL=https://fidalgosetup.blob.core.windows.net/cli-extensions
readonly NIX_CLI_VERSION=(
    0.1.0
)

# environments
readonly NIX_FIDALGO_WWW_ENVIRONMENTS=https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/20669/Environments

# const
readonly NIX_CODENAME="devcenter"
readonly NIX_CONST_EMPTY=

# hosts
readonly NIX_HOST_MICROSOFT_COM="microsoft.com"
readonly NIX_HOST_ONMICROSOFT_COM="onmicrosoft.com"
readonly NIX_HOST_MSFT_CCSCTP_NET="msft.ccsctp.net"
readonly NIX_HOST_PORTAL_COM="portal.azure.com"

# global (azure)
readonly NIX_CPC_LOCATION=westus3
readonly NIX_CPC_WWW_SUPPORED_LOCATIONS=https://docs.microsoft.com/en-us/windows-365/enterprise/requirements#supported-azure-regions-for-cloud-pc-provisioning
readonly NIX_FIDALGO_DATAPLANE_TOKEN_URL=https://devcenters.fidalgo.azure.com
readonly NIX_FIDALGO_DEFAULT_DNS_SUFFIX=devcenters.fidalgo.azure.com
readonly NIX_AZURE_LOCATION_DEFAULT=centraluseuap
readonly NIX_AZURE_CLOUD_DEFAULT=AzureCloud
readonly NIX_AZURE_CLOUD_DOGFOOD=Dogfood

# clouds (azure)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC=(
    ['endpoint-active-directory']='https://login.microsoftonline.com'
    ['endpoint-active-directory-graph-resource-id']='https://graph.windows.net/'
    ['endpoint-active-directory-resource-id']='https://management.core.windows.net/'
    ['endpoint-gallery']='https://gallery.azure.com/'
    ['endpoint-resource-manager']='https://management.azure.com/'
)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS_DOGFOOD=(
    ['endpoint-active-directory']='https://login.windows-ppe.net/'
    ['endpoint-active-directory-graph-resource-id']='https://graph.ppe.windows.net/'
    ['endpoint-active-directory-resource-id']='https://management.core.windows.net/'
    ['endpoint-gallery']='https://df.gallery.azure-test.net/'
    ['endpoint-resource-manager']='https://api-dogfood.resources.windows-int.net/'
    ['suffix-keyvault-dns']='azure-test.net'
)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS=(
    [${NIX_AZURE_CLOUD_DEFAULT}]="NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC"
    [${NIX_AZURE_CLOUD_DOGFOOD}]="NIX_AZURE_CLOUD_ENDPOINTS_DOGFOOD"
)
readonly NIX_AZURE_CLOUD_BUILTIN=(
    "${NIX_AZURE_CLOUD_DEFAULT}"
    AzureChinaCloud
    AzureUSGovernment
    AzureGermanCloud
)

readonly -A NIX_UPN_OVERRIDE=(
    ['msft.ccsctp.net']=true
    ['onmicrosoft.com']=true
)

# fidalgo ad groups
readonly NIX_AD_GROUP_X2FA="MFA Excluded Users"
readonly NIX_AD_GROUP_ADMINS="Admins"

# accounts
readonly NIX_ACCOUNT_MFA_ACTIVATION_TIMEOUT_MINUTES=3
readonly NIX_ACCOUNT_ADMIN='admin'
readonly NIX_ACCOUNT_USER='user'
readonly NIX_ACCOUNT_USER_SYNC='sync'

# fidalgo personas
readonly NIX_PERSONA_ADMINISTRATOR='administrator'
readonly NIX_PERSONA_DEVELOPER='developer'
readonly NIX_PERSONA_NETWORK_ADMINISTRATOR='network-administrator'
readonly NIX_PERSONA_VM_USER='vm-user' # is developer except in dogfood
readonly NIX_PERSONA_VM_USER_SYNC='vm-user-sync' # is developer except in dogfood
readonly NIX_PERSONA_ME='me'
readonly -A NIX_PERSONA_UPN=(
    ["${NIX_PERSONA_ADMINISTRATOR}"]='NIX_FID_UPN_DOMAIN_ADMIN'
    ["${NIX_PERSONA_DEVELOPER}"]='NIX_FID_UPN_DOMAIN_USER'
    ["${NIX_PERSONA_NETWORK_ADMINISTRATOR}"]='NIX_CPC_UPN_DOMAIN_ADMIN'
    ["${NIX_PERSONA_VM_USER}"]='NIX_CPC_UPN_DOMAIN_USER'
    ["${NIX_PERSONA_VM_USER_SYNC}"]='NIX_CPC_UPN_DOMAIN_USER_SYNC'
    ["${NIX_PERSONA_ME}"]='NIX_UPN_MICROSOFT'
)
readonly -A NIX_PERSONA_CLOUD=(
    ["${NIX_PERSONA_ADMINISTRATOR}"]='FID'
    ["${NIX_PERSONA_DEVELOPER}"]='FID'
    ["${NIX_PERSONA_NETWORK_ADMINISTRATOR}"]='CPC'
    ["${NIX_PERSONA_VM_USER}"]='CPC'
    ["${NIX_PERSONA_VM_USER_SYNC}"]='CPC'
)
readonly -A NIX_PERSONA_VARIABLE=(
    ["${NIX_PERSONA_ADMINISTRATOR}"]='NIX_ENV_PERSONA_ADMINISTRATOR'
    ["${NIX_PERSONA_DEVELOPER}"]='NIX_ENV_PERSONA_DEVELOPER'
    ["${NIX_PERSONA_NETWORK_ADMINISTRATOR}"]='NIX_ENV_PERSONA_NETWORK_ADMINISTRATOR'
    ["${NIX_PERSONA_VM_USER}"]='NIX_ENV_PERSONA_VM_USER'
    ["${NIX_PERSONA_VM_USER_SYNC}"]='NIX_ENV_PERSONA_VM_USER_SYNC'
    ["${NIX_PERSONA_ME}"]='NIX_ENV_PERSONA_ME'
)

readonly NIX_TEST_ENVIRONMENTS=(
    DOGFOOD
    DOGFOOD-INT
    SELFHOST
    PPE
)

# TODO : Remove environment constants so NIX can be publicly published

# public (azure)
readonly NIX_PUBLIC_NAME=PUBLIC
readonly NIX_PUBLIC_CPC=${NIX_PUBLIC_NAME}
readonly NIX_PUBLIC_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_PUBLIC_KUSTO=PUBLIC
readonly NIX_PUBLIC_DNS=10.1.0.4

# selfhost (azure)
readonly NIX_SELFHOST_NAME=SELFHOST
readonly NIX_SELFHOST_CPC=${NIX_SELFHOST_NAME}
readonly NIX_SELFHOST_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_SELFHOST_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_SELFHOST_KUSTO=PUBLIC
readonly NIX_SELFHOST_WWW_MEM=https://aka.ms/cpcsh
readonly NIX_SELFHOST_WWW_END_USER=https://aka.ms/cpc-iwp-sh
readonly NIX_SELFHOST_DC_VNET_RESOURCE_GROUP=Networks
readonly NIX_SELFHOST_DC_VNET=DomainController-vnet
readonly NIX_SELFHOST_DC_RESOURCE_GROUP=DomainController
readonly NIX_SELFHOST_DC=DomainController
readonly NIX_SELFHOST_DNS=10.1.0.4

# int (azure)
readonly NIX_INT_NAME=INT
readonly NIX_INT_CPC=${NIX_INT_NAME}
readonly NIX_INT_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_INT_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_INT_KUSTO=PUBLIC
readonly NIX_INT_WWW_MEM=https://aka.ms/cpcint
readonly NIX_INT_WWW_END_USER=https://aka.ms/cpc-iwp-int
readonly NIX_INT_DC_VNET_RESOURCE_GROUP=Networks
readonly NIX_INT_DC_VNET=WestUS2-VNet
readonly NIX_INT_DC_RESOURCE_GROUP=DomainController
readonly NIX_INT_DC=DomainController
readonly NIX_INT_DNS=10.1.0.4

# dogfood (azure)
readonly NIX_DOGFOOD_NAME=DOGFOOD
readonly NIX_DOGFOOD_CPC=${NIX_SELFHOST_NAME}
readonly NIX_DOGFOOD_PORTAL_HOST="df.onecloud.azure-test.net"
readonly NIX_DOGFOOD_KUSTO=DOGFOOD

# dogfood-int (azure)
readonly NIX_DOGFOOD_INT_NAME=DOGFOOD_INT
readonly NIX_DOGFOOD_INT_CPC=${NIX_INT_NAME}
readonly NIX_DOGFOOD_INT_LOCATION=${NIX_DOGFOOD_LOCATION}
readonly NIX_DOGFOOD_INT_KUSTO=${NIX_DOGFOOD_KUSTO}

# ppe (azure)
readonly NIX_PPE_NAME=PPE
readonly NIX_PPE_CPC=${NIX_PPE_NAME}
readonly NIX_PPE_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_PPE_KUSTO=PUBLIC
readonly NIX_PPE_WWW_MEM=https://aka.ms/cpccanary
readonly NIX_PPE_WWW_END_USER=https://aka.ms/cpc-iwp-ppe 
readonly NIX_PPE_DC_VNET_RESOURCE_GROUP=fidalgoppe010
readonly NIX_PPE_DC_VNET=vNet
readonly NIX_PPE_DC_RESOURCE_GROUP=fidalgoppe010
readonly NIX_PPE_DC=ADWinVM
readonly NIX_PPE_DNS=10.1.0.4

readonly NIX_HIT_ORDER=(
    query
    segment
    port
    host
    scheme
    method
    header
    type
    data
)

readonly NIX_TEST_OP_ORDER=(
    activation
    nominate
    user
    assemble
    new
    assign
    set
    name
    parent
    group
    subscription
    location
    ref
    pointer
    context
    spid
    persona
    env
    option
    option-list
    secret
    secret-id
    grant
    secure
    # delete
)

readonly NIX_TEST_OPTION_ORDER=(
    name
    parent
    group
    subscription
)

readonly -A NIX_TEST_KNOWN_OPTIONS=(
    ['name']='name'
    ['resource-group']='group'
    ['subscription']='subscription'
    ['location']='location'
)

readonly NIX_HTTP='http://'
readonly NIX_HTTP_SECURE='https://'

# http headers
readonly NIX_HTTP_HEADER_ACCEPT='Accept'
readonly NIX_HTTP_HEADER_AUTHORIZATION='Authorization'
readonly NIX_HTTP_HEADER_CONTENT_TYPE='Content-Type'

# http application
readonly NIX_HTTP_APPLICATION_JSON='application/json'

# http method
readonly NIX_HTTP_METHOD_GET='GET'
readonly NIX_HTTP_METHOD_POST='POST'
readonly NIX_HTTP_METHOD_PATCH='PATCH'
readonly NIX_HTTP_METHOD_PUT='PUT'
readonly NIX_HTTP_METHOD_DELETE='DELETE'

# networking
readonly NIX_HTTP_PORT=80
readonly NIX_HTTP_DATAPLANE_PORT=5001 



# shim
declare -g VPT_DIR_REPO="${NIX_REPO_DIR}"

# log
declare -g VPT_LOG="/tmp/vpt.log"

# you-up
declare -g VPT_UUP_TIMEOUT=32
declare -g VPT_SSH_TIMEOUT=32

# azure login
declare -g VPT_AZURE_TENANT
declare -g VPT_AZURE_SUBSCRIPTION

# user
declare -g VPT_USER_PRIVATE_KEY="${HOME}/.ssh/id_rsa"

# dirs
declare -g VPT_DIR_SRC=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
declare -g VPT_DIR_SSH="${VPT_DIR_REPO}/.ssh"

# tools
declare -g VPT_TOOL_AZ_INSTALL_SCRIPT='https://aka.ms/InstallAzureCLIDeb'
declare -g VPT_TOOL_AZBRIDGE_REPO='https://github.com/kingces95/azure-relay-bridge-binaries'
declare -g VPT_TOOL_AZBRIDGE_REPO_DIR="${HOME}/azure-relay-bridge-binaries"
declare -g VPT_TOOL_AZBRIDGE_DEB='azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb'

# keys
declare -g VPT_SSH_PRIVATE_KEY="${VPT_DIR_SSH}/id_rsa"
declare -g VPT_SSH_PUBLIC_KEY="${VPT_DIR_SSH}/id_rsa.pub"

# azure
declare -g VPT_AZURE_TAG="ppe"
declare -g VPT_AZURE_PREFIX="vpt-${VPT_AZURE_TAG}"
declare -g VPT_AZURE_LOCATION='westus'
declare -g VPT_AZURE_GROUP="${VPT_AZURE_PREFIX}-rg"

# azure relay
declare -g VPT_AZURE_RELAY_NAMESPACE="${VPT_AZURE_PREFIX}-relay"
declare -g VPT_AZURE_RELAY_NAME='bridge'

# ssh
declare -g VPT_SSH_DEFAULTS=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o LogLevel=ERROR
)

# service
declare -g VPT_SSH_IP=127.0.0.1
declare -g VPT_SSH_PORT=2222

# service <- relay remote
declare -g VPT_AZURE_RELAY_REMOTE_IP=127.0.0.1
declare -g VPT_AZURE_RELAY_REMOTE_PORT="${VPT_SSH_PORT}"

# service <- relay remote <- relay local
declare -g VPT_AZURE_RELAY_LOCAL_IP=127.0.0.2
declare -g VPT_AZURE_RELAY_LOCAL_PORT=$(( VPT_SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
declare -g VPT_SOCKS5H_IP=127.0.0.1
declare -g VPT_SOCKS5H_PORT=$(( VPT_AZURE_RELAY_LOCAL_PORT + 1 )) # 2224
declare -g VPT_SOCKS5H_URL="socks5h://${VPT_SOCKS5H_IP}:${VPT_SOCKS5H_PORT}"

# anonymous
declare -g VPT_ANONYMOUS=anon
declare -g VPT_ANONYMOUS_UPN="${VPT_ANONYMOUS}@127.0.0.2"
declare -g VPT_ANONYMOUS_DIR="/home/${VPT_ANONYMOUS}"
declare -g VPT_ANONYMOUS_AUTHORIZED_KEYS="${VPT_ANONYMOUS_DIR}/.ssh/authorized_keys"

# testing
declare -g VPT_MYIP='https://api.ipify.org'