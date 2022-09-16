alias az-enum-resource="nix::azure::resource::enum | nix::record::align 2"
alias az-who="nix::azure::who"

nix::az::account::get_access_token::check() {
    nix::az::account::get_access_token >/dev/null 2>&1
}

nix::azure::resource::enum() {
    nix::bash::elements NIX_AZURE_RESOURCE_ACTIVATION_ORDER \
        | nix::record::number
}

nix::azure::who() {
    if ! nix::az::account::get_access_token::check; then
        return
    fi

    cat <<-EOF
		az
		    user                    $(nix::az::signed_in_user::upn)
		    user-id                 $(nix::az::signed_in_user::id)
		    subscription            $(nix::az::account::show::subscription::name)
		    subscription-id         $(nix::az::account::show::subscription::id)
		    tenant-id               $(nix::az::account::show::tenant::id)
		    cloud                   $(nix::az::cloud::which)
		
		env
		    AZURE_CONFIG_DIR        ${AZURE_CONFIG_DIR}
		    AZURE_CLOUD_NAME        ${AZURE_CLOUD_NAME}
		    AZURE_DEFAULTS_GROUP    ${AZURE_DEFAULTS_GROUP}
		    AZURE_DEFAULTS_LOCATION ${AZURE_DEFAULTS_LOCATION}
		
		EOF
}

nix::azure::id::subnet() {
    local SUBSCRIPTION=$1
    shift

    local RESOURCE_GROUP=$1
    shift

    local VNET=$1
    shift

    local SUBNET=$1
    shift
    
    nix::azure::id "${SUBSCRIPTION}" "${RESOURCE_GROUP}" 'subnet' "${SUBNET}" "${VNET}" 
}

nix::azure::id() {
    local SUBSCRIPTION=$1
    shift

    local RESOURCE_GROUP=$1
    shift

    local RESOURCE=$1
    shift

    local NAME=$1
    shift

    local PARENT=$1
    shift

    ID="/subscriptions/${SUBSCRIPTION}"
    if [[ "${RESOURCE_GROUP}" ]]; then

        ID+="/resourceGroups/${RESOURCE_GROUP}"
        if [[ "${RESOURCE}" ]]; then

            if [[ ! "${PARENT}" ]]; then
                ID+="/providers/${NIX_AZURE_RESOURCE_PROVIDER[${RESOURCE}]}"
            else
                local PARENT_RESOURCE="${NIX_AZURE_RESOURCE_PARENT[${RESOURCE}]}"
                ID+="/providers/${NIX_AZURE_RESOURCE_PROVIDER[${PARENT_RESOURCE}]}"
                ID+="/${PARENT}/${NIX_AZURE_RESOURCE_PROVIDER[${RESOURCE}]}"
            fi
            ID+="/${NAME}"
        fi
    fi

    echo "${ID}"
}