nix::http::header() {
    echo "$1: $2"
}

nix::http::header::accept() {
    # Accept: */*
    local VALUE=${1-'*/*'}
    nix::http::header "${NIX_HTTP_HEADER_ACCEPT}" "${VALUE}" 
}

nix::http::header::content_type::json() {
    # Content-Type: application/json
    local VALUE=${1-${NIX_HTTP_APPLICATION_JSON}}
    nix::http::header "${NIX_HTTP_HEADER_CONTENT_TYPE}" "${VALUE}" 
}

nix::http::header::authorization::bearer() {
    # Authorization: Bearer eyJhbGciO...
    local VALUE="$1"
    nix::http::header "${NIX_HTTP_HEADER_AUTHORIZATION}" "Bearer ${VALUE}" 
}