(
    set -e
    fd-login-as-administrator
    az group create \
        --name ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --location ${NIX_FID_LOCATION}
    az devcenter admin devcenter create \
        --name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --identity-type SystemAssigned \
        --location ${NIX_FID_LOCATION}
    az keyvault create \
        --name ${NIX_ENV_PREFIX}-ghkv \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --enable-rbac-authorization true \
        --location ${NIX_FID_LOCATION}
    az role assignment create \
        --assignee ${NIX_ENV_PERSONA_ADMINISTRATOR} \
        --role "Key Vault Administrator" \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/${NIX_ENV_PREFIX}-ghkv \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az role assignment create \
        --assignee $(az-ad-sp-id ${NIX_ENV_PREFIX}-dc) \
        --role "Key Vault Secrets User" \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/${NIX_ENV_PREFIX}-ghkv \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az keyvault secret set \
        --value "$(fd-secret-github-pat)" \
        --name github-pat \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --vault-name ${NIX_ENV_PREFIX}-ghkv
    az devcenter admin catalog create \
        --name ${NIX_ENV_PREFIX}-my-github-catalog \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --git-hub \
            branch="${NIX_GITHUB_CATALOG_BRANCH}" \
            path="${NIX_GITHUB_CATALOG_PATH}" \
            secret-identifier=$(fd-secret-id github-pat ${NIX_ENV_PREFIX}-ghkv ${NIX_FID_SUBSCRIPTION}) \
            uri="${NIX_GITHUB_CATALOG_URL}"
    az devcenter admin environment-type create \
        --name ${NIX_ENV_PREFIX}-my-environment-type \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin project create \
        --name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --dev-center-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc \
        --location ${NIX_FID_LOCATION}
    az role assignment create \
        --assignee ${NIX_ENV_PERSONA_DEVELOPER} \
        --role "DevCenter Dev Box User" \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin mapping create \
        --name ${NIX_ENV_PREFIX}-my-mapping \
        --dev-center-name ${NIX_ENV_PREFIX}-dc \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --environment-type ${NIX_ENV_PREFIX}-my-environment-type \
        --mapped-subscription-id /subscriptions/${NIX_FID_SUBSCRIPTION} \
        --project-id /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project
    az role assignment create \
        --assignee $(az-ad-sp-id ${NIX_ENV_PREFIX}-dc) \
        --role owner \
        --scope /subscriptions/${NIX_FID_SUBSCRIPTION} \
        --subscription ${NIX_FID_SUBSCRIPTION}
    az devcenter admin environment create \
        --name ${NIX_ENV_PREFIX}-my-kv-environment \
        --project-name ${NIX_ENV_PREFIX}-my-project \
        --resource-group ${NIX_FID_RESOURCE_GROUP} \
        --subscription ${NIX_FID_SUBSCRIPTION} \
        --catalog-item-name DeployKeyVault \
        --deployment-parameters '{ "keyVaultNamePrefix": { "value": "my-prefix" } }' \
        --environment-type ${NIX_ENV_PREFIX}-my-environment-type
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project/environments/${NIX_ENV_PREFIX}-my-kv-environment
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/mappings/${NIX_ENV_PREFIX}-my-mapping
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/projects/${NIX_ENV_PREFIX}-my-project
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/environmenttypes/${NIX_ENV_PREFIX}-my-environment-type
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc/catalogs/${NIX_ENV_PREFIX}-my-github-catalog
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/${NIX_ENV_PREFIX}-ghkv
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Devcenter/devcenters/${NIX_ENV_PREFIX}-dc
    az resource delete \
        --ids /subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}
)
