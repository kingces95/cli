This walkthrough verifies the fix for
> [Bug 1533938](https://dev.azure.com/devdiv/OnlineServices/_sprints/taskboard/Azure%20Lab%20Services%20-%20Fidalgo/OnlineServices/Copper/CY22%20Q2/2Wk/2Wk3?workitem=1533938): NetworkSettings creation does not validate domainJoinType field. 

We expect if `--domain-join-type` is not `HybridAzureADJoin` or `AzureADJoin`, then we fail with error message:
```
The network settings type must be either HybridAzureADJoin or AzureADJoin.
```
Passing a bad `--domain-join-type` from the command line returns:
```
$ az fidalgo admin network-setting create \
    --domain-join-type=HybridAzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --domain-name=mydomainname \
    --domain-password=mydomainpassword \
    --domain-username=mydomainusername \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION}
```
```
az fidalgo admin network-setting create: 'HybridAzureADJoin-bad' is not a valid value for '--domain-join-type'. Allowed values: HybridAzureADJoin, AzureADJoin.
```
While correct, we do not get the error message we expect. This is because the CLI has trapped for the bad arguments before sending the request. Bypass the CLI by placing the call directly using `curl`:
```
~/git/azure-devtest-center/http/rp $ cat-http \
    ./subscriptions/resourceGroups/providers/networksettings/create-hybrid.json \
    --domain-join-type=HybridAzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --domain-name=mydomainname \
    --domain-password=mydomainpassword \
    --domain-username=mydomainusername \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    | http-curl | cmd | exe | jq
```

```json
{
  "error": {
    "code": "ValidationError",
    "message": "The request is not valid.",
    "details": [
      {
        "code": "InvalidNetworkSettingsType",
        "target": "Properties.DomainJoinType",
        "message": "The network settings type must be either HybridAzureADJoin or AzureADJoin.",
        "details": [],
        "additionalInfo": []
      }
    ]
  }
}
```
We get the the expected error message when we hit the service directly.

The json request proceeds as a pipeline. The stages of the pipeline are `cat-http`, `http-curl`, `cmd`, `exe`, `jq`. Here are the results of each stage of the pipeline.
```
~/git/azure-devtest-center/http/rp $ cat-http \
    ./subscriptions/resourceGroups/providers/networksettings/create-hybrid.json
```
```
port 443 
host management.azure.com 
scheme https:// 
query api-version 2022-03-01-privatepreview
segment subscriptions
segment --subscription
segment resourceGroups
segment --resource-group
segment providers
segment Microsoft.Devcenter
segment networksettings
segment --name
method put
create-hybrid.json"
{
    "location": "--location",
    "properties": {
        "subnetId": "--subnet-id",
        "domainName": "--domain-name",
        "domainUsername": "--domain-username",
        "domainPassword": "--domain-password",
        "domainJoinType": "--domain-join-type"
    }
}
```
```
~/git/azure-devtest-center/http/rp $ cat-http \
    ./subscriptions/resourceGroups/providers/networksettings/create-hybrid.json \
    --domain-join-type=HybridAzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --domain-name=mydomainname \
    --domain-password=mydomainpassword \
    --domain-username=mydomainusername \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION}
```
```
port 443 
host management.azure.com 
scheme https:// 
query api-version 2022-03-01-privatepreview
segment subscriptions
segment 974ae608-fbe5-429f-83ae-924a64019bf3
segment resourceGroups
segment nix-chrkin-ppe-rg
segment providers
segment Microsoft.Devcenter
segment networksettings
segment nix-chrkin-ppe-my-network-setting
method put
declare -- JSON="./subscriptions/resourceGroups/providers/networksettings/create-hybrid.json"
{
    "location": "centraluseuap",
    "properties": {
        "subnetId": "/subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/nix-chrkin-ppe-rg/providers/Microsoft.Network/virtualNetworks/nix-chrkin-ppe-my-vnet/subnets/nix-chrkin-ppe-mysubnet",
        "domainName": "mydomainname",
        "domainUsername": "mydomainusername",
        "domainPassword": "mydomainpassword",
        "domainJoinType": "HybridAzureADJoin-bad"
    }
}
```
```
~/git/azure-devtest-center/http/rp $ cat-http \
    ./subscriptions/resourceGroups/providers/networksettings/create-hybrid.json \
    --domain-join-type=HybridAzureADJoin-bad \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --domain-name=mydomainname \
    --domain-password=mydomainpassword \
    --domain-username=mydomainusername \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    | http-curl
```
```
command name curl
command argument https://management.azure.com:443/subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/nix-chrkin-ppe-rg/providers/Microsoft.Devcenter/networksettings/nix-chrkin-ppe-my-network-setting?api-version=2022-03-01-privatepreview
flag s
option H Content-Type: application/json
option H Accept: */*
option H Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
option X PUT
option d {"location":"centraluseuap","properties":{"subnetId":"/subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/nix-chrkin-ppe-rg/providers/Microsoft.Network/virtualNetworks/nix-chrkin-ppe-my-vnet/subnets/nix-chrkin-ppe-mysubnet","domainName":"mydomainname","domainUsername":"mydomainusername","domainPassword":"mydomainpassword","domainJoinType":"HybridAzureADJoin-bad"}}
```
etc...