TZ='Pacific/Honolulu'

readonly NIX_MY_DISPLAY_NAME="Chris King"
readonly NIX_MY_TZ_OFFSET=-10h
readonly NIX_MY_IP_ALLOCATION="10.100.0.0/16"
readonly NIX_MY_ENVIRONMENTS=(
    DOGFOOD_INT
    DOGFOOD
    SELFHOST
    INT
    PPE
)
# readonly NIX_MY_DEFAULT_PROFILE=administrator
# readonly NIX_MY_DEFAULT_ENVIRONMENT=PPE

readonly NIX_KUSTO_TIME_FORMAT='hh:mm:ss-tt'

readonly NIX_PERSONAL_CLOUD='AzureCloud'
readonly NIX_PERSONAL_CLOUD_ENDPOINTS='NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC'
readonly NIX_PERSONAL_UPN='kingces95@gmail.com'
readonly NIX_PERSONAL_TENANT='385bd7ec-08a1-4afd-8539-1b73531c8f98'
readonly NIX_PERSONAL_SUBSCRIPTION=2'a70945f-013c-4283-bc06-e96f5f04d689'
readonly NIX_PERSONAL_SUBSCRIPTION_NAME='Visual Studio Enterprise Subscription'
readonly NIX_PERSONAL_RESOURCE_GROUP='kingces95-rg'
readonly NIX_PERSONAL_LOCATION='westus3'

readonly NIX_PERSONAL_KEYVAULT_ID_RSA='id-rsa'
readonly NIX_PERSONAL_KEYVAULT_ID_RSA_PUB='id-rsa-pub'
readonly NIX_PERSONAL_KEYVAULT='kingces95-kv'

# https://portal.fidalgo.azure.com/ multiple dev-box portal
# 0 - Pull Request 396016: Pool cannot patch network settings with different ad join type. 
#       Now bug 1537283. https://dev.azure.com/devdiv/OnlineServices/_workitems/edit/1537283

# 1 - Pull Request 397830: Return not a guest in local or dogfood test environment. Now bug 1537547 Failed to create CPC.
# 2 - Pull Request 397830: Return not a guest in local or dogfood test environment. Now bug 1537547 Failed to create CPC. Reproduction.
#       https://dev.azure.com/devdiv/OnlineServices/_sprints/taskboard/Azure%20Lab%20Services%20-%20Fidalgo/OnlineServices/Copper/CY22%20Q2/2Wk/2Wk3

# 3 - Pull Request 396016: Pool cannot patch network settings with different ad join type. 
# 4 - aadj; Retry creation of CPC; Failed
# 5 - aadj-hybrid; try establish basline using HybridAadj now that DC is healthy; 
#            Oops. Forgot to use DC network. Cannot cleanup network-settings because of Bug 1537283
# 6 - aadj-hybrid; try establish basline using HybridAadj now that DC is healthy; failed. Renamed everything. Will run again.
# 7 - aadj; Retry creation of CPC for reporting to channel; Failed but did more re-names
# 8 - aadj; Retry creation of CPC for reporting to channel; Also in INT; In INT Forbidden to create network settings; In SF cannot delete NetworkSettings in wrong region
# 9 - aadj; Retry in SelfHost with correct location (did attached network last) worked!
# 10 - aadj; Retry in SelfHost with correct location (do attached network early) 
# 11 - bug 1487564
# 12 - new test framework; blocked by Bug 1551855: Failed Pool Creation due to bad NetworkSettingsId
# 13 - try new hybrid-ad.sh
# 14 - bug 1487564 - fully generated
# 16 - bug 1487564, 1472319 - fully generated
# 17 - Selfhost W365 integration test failures due to unavailable Azure Connection (OPNC). (Chris King)
# 18
# 19 - 
# 20 - 
# 21 - azure-ad.sh dogfood ppe
# 27 - private link demo
# 28 - azure-ad.sh - not yet tried to delete
# 29 - hybrid-ad.sh - failed to delete
# 30 - switch.sh
# 30 - demo/private-link/storage
# 32 - md deploy.sh
# 33 - md switch.sh cli 0.4.0
# 35 - switch.sh cli 0.4.0 + correct PPE subscription
# 36 - deploy.sh - failed at az devcenter admin catalog create
# 37 - azure-ad
# 38 - hybrid-ad
# 50 - DEMO
# 54 - testing on devbox
# 57 - test switch on dogfood
# 62 - 1578364
# 63 - 1593977
# 63 - 1590780 Azure
# 67 - 1593759 Require tags
readonly NIX_MY_ENV_ID=67

source "${NIX_HOME}/alias.sh"

# cat $FILE | jq '. |  {RefreshToken:.RefreshToken,Account:.Account}'
# secret-identifier="$(fd-secret-id github-pat ${NIX_ENV_PREFIX}-ghkv ${NIX_FID_SUBSCRIPTION})"

# test env/secret/ref persona
# make az profile readonly
# docker development
# fast loading, cloud caching
# fail fast loading
# atomic switching
# democratize az commands
# harvest subscriptions
# live cpu usage
# background task as test runner
# lint alias/function names
# warn if kusto query exceeds 90 days
# detect callee/caller cycles between namespaces

nix::snippit() {
    # printf '%s\n' main "$(lsof -p $$ | grep dev)" > /dev/stderr

    echo ls -l /proc/$BASHPID/fd
    ls -l /proc/$BASHPID/fd

    pipe() {
        # printf '%s %s:%s %s\n' $1 $BASHPID $BASH_SUBSHELL $$ > /dev/stderr
        # printf '%s\n' $1 "$(lsof -p $BASHPID | grep dev)" > /dev/stderr
        cat
        echo $1
        echo ls -l /proc/$BASHPID/fd
        ls -l /proc/$BASHPID/fd
    }

    echo hi | pipe a | pipe b | pipe c | pipe d
}

nix::env::diff() {
    nix::record::diff <(nix) <("$@"; nix)
}

nix::record::diff() {
    local BEFORE="$1"
    shift

    local AFTER="$1"
    shift

    diff "${BEFORE}" "${AFTER}" \
        --unchanged-line-format="" \
        --new-line-format="+ %L" \
        --old-line-format="- %L" \
        | sort -k2,2 -k1,1r
}

# Bug 1487564: Incorrectly formatted parameters lead to 500 on environment deployment
# Bug 1472319: Environment creation fails with internal server error when authentication errors occur.

# [19 DOGFOOD developer] .../ $     az fidalgo dev virtual-machine create \
# >         --name ${NIX_ENV_PREFIX}-my-vm \
# >         --project-name ${NIX_ENV_PREFIX}-my-project \
# >         --subscription ${NIX_FID_SUBSCRIPTION} \
# >         --dev-center ${NIX_ENV_PREFIX}-my-dev-center \
# >         --fidalgo-dns-suffix "${NIX_FID_DNS_SUFFIX}" \
# >         --pool-name ${NIX_ENV_PREFIX}-my-pool \
# >         --user-id $(fd-login-as-vm-user; az-signed-in-user-id)
# nix: az: installing fidalgo-0.3.2-py3-none-any.whl 
# Command group 'fidalgo' is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
# <urllib3.connection.HTTPSConnection object at 0x7f9c89364820>: Failed to establish a new connection: [Errno 110] Connection timed out

# [19 PPE developer] .../ $     az fidalgo dev virtual-machine create \
# >         --name ${NIX_ENV_PREFIX}-my-vm \
# >         --project-name ${NIX_ENV_PREFIX}-my-project \
# >         --subscription ${NIX_FID_SUBSCRIPTION} \
# >         --dev-center ${NIX_ENV_PREFIX}-my-dev-center \
# >         --fidalgo-dns-suffix "${NIX_FID_DNS_SUFFIX}" \
# >         --pool-name ${NIX_ENV_PREFIX}-my-pool \
# >         --user-id $(fd-login-as-vm-user; az-signed-in-user-id)
# Command group 'fidalgo' is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
# (VirtualMachineNotFound) The virtual machine resource was not found.
# Code: VirtualMachineNotFound
# Message: The virtual machine resource was not found.

# [20 PPE] .../ $     az fidalgo admin pool update \
# >         --name ${NIX_ENV_PREFIX}-my-pool \
# >         --project-name ${NIX_ENV_PREFIX}-my-project \
# >         --resource-group ${NIX_FID_RESOURCE_GROUP} \
# >         --subscription ${NIX_FID_SUBSCRIPTION} \
# >         --network-connection-name ${NIX_ENV_PREFIX}-my-azure-ad-attached-network
# Command group 'fidalgo' is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
# (InternalServerError) The service encountered an internal error and was unable to complete the request. Retry the operation later, and contact support if this error persists.
# Code: InternalServerError
# Message: The service encountered an internal error and was unable to complete the request. Retry the operation later, and contact support if this error persists.

# [20 DOGFOOD] .../nix/tst/sh/ 2 $     az fidalgo admin network-setting show-health-detail \
# >         --name ${NIX_ENV_PREFIX}-my-hybrid-ad-network-setting \
# >         --resource-group ${NIX_FID_RESOURCE_GROUP} \
# >         --subscription ${NIX_FID_SUBSCRIPTION}
# Command group 'fidalgo' is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
# {
#   "endDateTime": "2022-06-28T00:45:19+00:00",
#   "healthChecks": [
#     {
#       "additionalDetails": null,
#       "displayName": "Azure AD device sync",
#       "endDateTime": "2022-06-28T00:45:19.041331+00:00",
#       "errorType": null,
#       "recommendedAction": null,
#       "startDateTime": "2022-06-28T00:45:18.938838+00:00",
#       "status": "Passed"
#     },
#     {
#       "additionalDetails": null,
#       "displayName": "Azure tenant readiness",
#       "endDateTime": "2022-06-28T00:45:19.154658+00:00",
#       "errorType": null,
#       "recommendedAction": null,
#       "startDateTime": "2022-06-28T00:45:19.140212+00:00",
#       "status": "Passed"
#     },
#     {
#       "additionalDetails": null,
#       "displayName": "Azure virtual network readiness",
#       "endDateTime": "2022-06-28T00:45:19.231976+00:00",
#       "errorType": "ResourceAvailabilityCheckUnsupportedVNetRegion",
#       "recommendedAction": "The selected vNet is located in an unsupported region. Ensure that the selected vNet is located in a supported region.",
#       "startDateTime": "2022-06-28T00:45:19.221904+00:00",
#       "status": "Failed"
#     }
#   ],
#   "id": null,
#   "name": null,
#   "startDateTime": "2022-06-28T00:45:18+00:00",
#   "systemData": null,
#   "type": null
# }
# [20 DOGFOOD] .../nix/tst/sh/ $ echo $NIX_FID_LOCATION
# centralus

# [21 DOGFOOD] .../ $     az fidalgo admin network-setting show-health-detail \
# >         --name ${NIX_ENV_PREFIX}-my-azure-ad-network-setting \
# >         --resource-group ${NIX_FID_RESOURCE_GROUP} \
# >         --subscription ${NIX_FID_SUBSCRIPTION}
#     {
#       "additionalDetails": null,
#       "displayName": "Environment and configuration is ready",
#       "endDateTime": "2022-07-08T20:55:20.788605+00:00",
#       "errorType": "InternalServerUnknownError",
#       "recommendedAction": "Provisioning has failed due to an internal error, Please see the raw error message for further information and contact support.",
#       "startDateTime": "2022-07-08T20:55:20.788605+00:00",
#       "status": "Failed"
#     }

# [chrkin 66 DOGFOOD] .../ $     az devcenter admin pool show \
# >         --name ${NIX_ENV_PREFIX}-my-pool \
# >         --project-name ${NIX_ENV_PREFIX}-my-project \
# >         --resource-group ${NIX_FID_RESOURCE_GROUP} \
# >         --subscription ${NIX_FID_SUBSCRIPTION}
# Command group 'devcenter' is experimental and under development. Reference and support levels: 
https://aka.ms/CLI_refstatus
# (InvalidRequestContent) The request content was invalid and could not be deserialized: 
# 'Unable to find a constructor to use for type Microsoft.Azure.OpenApi.Validation.Models.OperationInfo. 
# A class should either have a default constructor, one constructor with arguments or a constructor marked 
# with the JsonConstructor attribute. Path 'operationInfo.apiVersion', line 1, position 51.'.
# Code: InvalidRequestContent
# Message: The request content was invalid and could not be deserialized: 'Unable to find a constructor 
# to use for type Microsoft.Azure.OpenApi.Validation.Models.OperationInfo. A class should either have a 
# default constructor, one constructor with arguments or a constructor marked with the JsonConstructor 
# attribute. Path 'operationInfo.apiVersion', line 1, position 51.'.