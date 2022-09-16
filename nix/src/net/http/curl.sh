nix::http::curl::get() {
    NIX_CURL_METHOD=${NIX_HTTP_METHOD_GET} \
        nix::http::curl "$@" 2< /dev/null # no extra headers
}

nix::http::curl::put() {
    NIX_CURL_METHOD=${NIX_HTTP_METHOD_PUT} \
        nix::http::curl::json "$@"
}

nix::http::curl::patch() {
    NIX_CURL_METHOD=${NIX_HTTP_METHOD_PATCH} \
        nix::http::curl::json "$@"
}

nix::http::curl::json() {
    # compress json; Add Content-Type: application/json
    jq -c | nix::http::curl "$@" 2< <(
        nix::http::header::content_type::json
    )
}

nix::http::curl::headers() {
    # Context: header-value
    cat 

    # Accept: */*
    nix::http::header::accept

    # Authorization: Bearer eyJhbGciO...
    local NIX_CURL_TOKEN=${NIX_CURL_TOKEN-$(nix::az::account::get_access_token)}
    nix::http::header::authorization::bearer ${NIX_CURL_TOKEN}
}

nix::http::curl::cmd::options() {
    local KEY VALUE
    while read KEY VALUE; do
        echo "option H ${KEY} ${VALUE}"
    done
}

nix::http::curl::cmd::url() {
    local NIX_CURL_PATH=${NIX_CURL_PATH-$1}
    local NIX_CURL_PORT=${NIX_CURL_PORT-${NIX_HTTP_PORT}}
    local NIX_CURL_HOST=${NIX_CURL_HOST-${NIX_HOST_IP}}
    local NIX_CURL_SCHEME=${NIX_CURL_SCHEME-${NIX_HTTP_SECURE}}

    if [[ ! "${NIX_CURL_PATH}" ]]; then
        NIX_CURL_PATH=$(nix::bash::args "${NIX_CURL_SEGMENTS[@]}" | nix::line::join '/')
    fi
    
    local URL="${NIX_CURL_SCHEME}${NIX_CURL_HOST}:${NIX_CURL_PORT}/${NIX_CURL_PATH}"
    
    if (( "${#NIX_CURL_QUERY[@]}" > 0 )); then
        local QUERY=$(nix::bash::map::write NIX_CURL_QUERY '=' | nix::line::join '&')
        URL+="?${QUERY}"
    fi

    nix::cmd::argument "${URL}"
    # nix::cmd::flag 'v'
    nix::cmd::flag 's'
}

nix::http::curl::cmd::body() {
    local NIX_CURL_METHOD=${NIX_CURL_METHOD-${NIX_HTTP_METHOD_GET}}
    if [[ "${NIX_CURL_METHOD}" == 'PUT' ]] || [[ "${NIX_CURL_METHOD}" == 'POST' ]]; then
        nix::cmd::option 'X' "${NIX_CURL_METHOD}"
        nix::cmd::option 'd' "$(cat)"
    fi
}

nix::http::curl() {
    nix::cmd::name 'curl'
    nix::http::curl::cmd::url "$@"
    nix::http::curl::headers <&2 \
        | nix::http::curl::cmd::options
    nix::http::curl::cmd::body
}

# curl -v http://192.168.96.1:5001/projects/aadj-project-df/users/me/virtualmachines/aadj-vm0-df
