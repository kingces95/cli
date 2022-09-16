nix::test::il::line() {
    local OP="$1"
    local KEY="$2"
    local VALUE="$3"

    if [[ "${OP}" == 'option' ]]; then
        if nix::bash::map::test NIX_TEST_KNOWN_OPTIONS "${KEY}"; then
            OP="${NIX_TEST_KNOWN_OPTIONS[${KEY}]}"
        fi
    fi

    echo "${OP}" "${KEY}" "${VALUE}"
}

nix::test::il::activation() {
    local RESOURCE="$1"
    local NAME="$2"

    local CLOUD=$(nix::test::cloud "${RESOURCE}")
    echo 'activation' \
        "\${NIX_${CLOUD}_SUBSCRIPTION}" \
        "${RESOURCE}" \
        "\${NIX_ENV_PREFIX}-${NAME}"
}

nix::test::il::user() {
    local RESOURCE="$1"

    echo 'user' 'name' "${NIX_AZURE_RESOURCE_PERSONA[${RESOURCE}]}"
}

nix::test::il::new() {
    local RESOURCE="$1"

    echo 'new' 'type' "${RESOURCE}"
}

nix::test::il::ref() {
    local OPTION="$1"
    local VALUE="$2"

    echo 'ref' "${OPTION}" "${VALUE}"
}

nix::test::il::group() {
    local RESOURCE="$1"

    local CLOUD=$(nix::test::cloud "${RESOURCE}")
    echo 'group' 'resource-group' "\${NIX_${CLOUD}_RESOURCE_GROUP}"
}

nix::test::il::assemble() {
    local RESOURCE="$1"
            
    local CLOUD=$(nix::test::cloud "${RESOURCE}")
    echo 'assemble' \
        "\${NIX_${CLOUD}_RESOURCE_GROUP}" \
        "\${NIX_${CLOUD}_SUBSCRIPTION}" \
        "\${NIX_${CLOUD}_LOCATION}" 
}

nix::test::il::subscription() {
    local RESOURCE="$1"

    local CLOUD=$(nix::test::cloud "${RESOURCE}")
    echo 'subscription' 'subscription' "\${NIX_${CLOUD}_SUBSCRIPTION}"
}

nix::test::il::name() {
    local NAME="$1"

    echo 'name' 'name' "\${NIX_ENV_PREFIX}-${NAME}"
}

nix::test::il::location() {
    local RESOURCE="$1"

    local CLOUD=$(nix::test::cloud "${RESOURCE}")
    echo 'location' 'location' "\${NIX_${CLOUD}_LOCATION}"
}

nix::test::il::parent() {
    local RESOURCE="$1"
    local PARENT="$2"

    echo 'parent' \
        "${NIX_AZURE_RESOURCE_PARENT[${RESOURCE}]}-name" \
        "\${NIX_ENV_PREFIX}-${PARENT}"
}

nix::test::il::persona() {
    local OPTION="$1"
    local PERSONA="$2"

    echo 'persona' "${OPTION}" "${PERSONA}"
}

nix::test::il::pointer() {
    local OPTION="$1"
    local TARGET_RESOURCE="$2"
    local TYPE="$3"

    echo 'pointer' "${OPTION}" "${TARGET_RESOURCE}" "${TYPE}"
}

nix::test::il::new::group() {
    local GROUP="$1"
    local SUBSCRIPTION="$2"
    local LOCATION="$3"

    cat <<-EOF
		new type group
		name name ${GROUP}
		subscription subscription ${SUBSCRIPTION}
		location location ${LOCATION}
		EOF
}

nix::test::id::assignee() {
    local ASSIGNEE="$1"
    shift

    if nix::bash::map::test NIX_AZURE_RESOURCE "${ASSIGNEE}"; then
        echo 'pointer' 'assignee' "${ASSIGNEE}" 'spid'
    else
        echo 'persona' 'assignee' "${ASSIGNEE}"
    fi
}

nix::test::il::grant() {
    local ASSIGNEE="$1"
    local ROLE="$2"

    cat <<-EOF
		assign type role-assignment
		context subscription subscription
		$(nix::test::id::assignee ${ASSIGNEE})
		option role "${ROLE}"
		context scope id
		EOF
}

nix::test::il::nominate() {
    local ASSIGNEE="$1"
    local ROLE="$2"
    local TARGET_RESOURCE="$3"

    # user name ${USR} ???
    local CLOUD=$(nix::test::cloud "${ASSIGNEE}")

    cat <<-EOF
		assign type role-assignment
		option subscription \${NIX_${CLOUD}_SUBSCRIPTION}
		$(nix::test::id::assignee ${ASSIGNEE})
		option role ${ROLE}
        $(nix::test::il::pointer scope ${TARGET_RESOURCE} id)
		EOF
}

nix::test::il::secure::secret() {
    local NAME="$1"
    local SECRET="$2"

    cat <<-EOF
		set type secret
		option name ${NAME}
        context vault-name name
		context subscription subscription
        secret file ${SECRET}
		EOF
}

nix::test::il::delete() {
    local ID="$1"

    cat <<-EOF
		delete type resource
		option ids ${ID}
		EOF
}
