# https://dev.azure.com/devdiv/OnlineServices/_workitems/edit/1539813
# Fri May 13 07:17:50 UTC 2022            
# NIX_FID_CLI_VERSION=0.3.2
# NIX_CPC_CLI_VERSION=0.3.2

fd-login-as-network-administrator
az group create \
    --location=centralus \
    --name=nix-chrkin-df-int-10-rg
az network vnet create \
    --name=nix-chrkin-df-int-10-my-vnet \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=westus2 \
    --subscription=f4791044-4994-4266-8f75-d738453862cf
az network vnet subnet create \
    --name=nix-chrkin-df-int-10-my-subnet \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=f4791044-4994-4266-8f75-d738453862cf \
    --address-prefixes=10.0.0.0/24 \
    --delegations=Microsoft.Fidalgo/networkSettings \
    --vnet-name=nix-chrkin-df-int-10-my-vnet
fd-login-as-administrator
az group create \
    --location=centralus \
    --name=nix-chrkin-df-int-10-rg
az fidalgo admin dev-center create \
    --name=nix-chrkin-df-int-10-my-dev-center \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=centralus \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --identity-type=SystemAssigned
az fidalgo admin network-setting create \
    --name=nix-chrkin-df-int-10-my-network-setting \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=centralus \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --domain-join-type=AzureADJoin \
    --subnet-id=/subscriptions/f4791044-4994-4266-8f75-d738453862cf/resourceGroups/nix-chrkin-df-int-10-rg/providers/Microsoft.Network/virtualNetworks/nix-chrkin-df-int-10-my-vnet/subnets/nix-chrkin-df-int-10-my-subnet
az fidalgo admin attached-network create \
    --name=nix-chrkin-df-int-10-my-attached-network \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --dev-center-name=nix-chrkin-df-int-10-my-dev-center \
    --network-connection-resource-id=/subscriptions/699a5a77-12d2-422b-8a50-c4f94d5a8864/resourceGroups/nix-chrkin-df-int-10-rg/providers/Microsoft.Fidalgo/networksettings/nix-chrkin-df-int-10-my-network-setting
az fidalgo admin devbox-definition create \
    --name=nix-chrkin-df-int-10-my-devbox-definition \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=centralus \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --dev-center-name=nix-chrkin-df-int-10-my-dev-center \
    --image-reference=id=/subscriptions/f4791044-4994-4266-8f75-d738453862cf/resourceGroups/nix-chrkin-df-int-10-rg/providers/Microsoft.Fidalgo/devcenters/nix-chrkin-df-int-10-my-dev-center/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
    --sku-name=PrivatePreview
az fidalgo admin project create \
    --name=nix-chrkin-df-int-10-my-project \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=centralus \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --dev-center-id=/subscriptions/699a5a77-12d2-422b-8a50-c4f94d5a8864/resourceGroups/nix-chrkin-df-int-10-rg/providers/Microsoft.Fidalgo/devcenters/nix-chrkin-df-int-10-my-dev-center
az role assignment create \
    --assignee=chrkin@microsoft.com \
    --role=Contributor \
    --scope=/subscriptions/699a5a77-12d2-422b-8a50-c4f94d5a8864/resourceGroups/nix-chrkin-df-int-10-rg/providers/Microsoft.Fidalgo/projects/nix-chrkin-df-int-10-my-project \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864
az fidalgo admin pool create \
    --name=nix-chrkin-df-int-10-my-pool \
    --resource-group=nix-chrkin-df-int-10-rg \
    --location=centralus \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --network-connection-name=nix-chrkin-df-int-10-my-attached-network \
    --devbox-definition-name=nix-chrkin-df-int-10-my-devbox-definition \
    --project-name=nix-chrkin-df-int-10-my-project
fd-login-as-developer
az fidalgo dev virtual-machine create \
    --name=nix-chrkin-df-int-10-my-vm \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864 \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --fidalgo-dns-suffix=devcenters.fidalgo.azure-test.net \
    --pool-name=nix-chrkin-df-int-10-my-pool \
    --project-name=nix-chrkin-df-int-10-my-project \
    --user-id=$(fd-login-as-vm-user; az-signed-in-user-id)

az fidalgo admin dev-center show \
    --name=nix-chrkin-df-int-10-my-dev-center \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864
az fidalgo dev virtual-machine show \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --name=nix-chrkin-df-int-10-my-vm \
    --project-name=nix-chrkin-df-int-10-my-project
az fidalgo dev virtual-machine list \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --project-name=nix-chrkin-df-int-10-my-project
az fidalgo dev virtual-machine get-remote-connection \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --name=nix-chrkin-df-int-10-my-vm \
    --project-name=nix-chrkin-df-int-10-my-project
az fidalgo dev virtual-machine stop \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --name=nix-chrkin-df-int-10-my-vm \
    --project-name=nix-chrkin-df-int-10-my-project
az fidalgo dev virtual-machine delete \
    --dev-center=nix-chrkin-df-int-10-my-dev-center \
    --name=nix-chrkin-df-int-10-my-vm \
    --project-name=nix-chrkin-df-int-10-my-project \
    --yes
az fidalgo admin network-setting delete \
    --name=nix-chrkin-df-int-10-my-network-setting \
    --resource-group=nix-chrkin-df-int-10-rg
az fidalgo admin network-setting show \
    --name=nix-chrkin-df-int-10-my-network-setting \
    --resource-group=nix-chrkin-df-int-10-rg 
az fidalgo admin attached-network show \
    --dev-center-name=nix-chrkin-df-int-10-my-dev-center \
    --name=nix-chrkin-df-int-10-my-attached-network \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864
az fidalgo admin network-setting show-health-detail \
    --name=nix-chrkin-df-int-10-my-network-setting \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=699a5a77-12d2-422b-8a50-c4f94d5a8864
az network vnet show \
    --name=nix-chrkin-df-int-10-my-vnet \
    --resource-group=nix-chrkin-df-int-10-rg \
    --subscription=f4791044-4994-4266-8f75-d738453862cf

az group delete \
    --name nix-chrkin-df-int-10-rg
az group delete \
    --name nix-chrkin-df-int-10-rg

while true; do
    az fidalgo dev virtual-machine show \
        --dev-center=nix-chrkin-df-int-10-my-dev-center \
        --name=nix-chrkin-df-int-10-my-vm \
        --project-name=nix-chrkin-df-int-10-my-project \
        --query provisioningState \
        --output tsv
    sleep 10
done
