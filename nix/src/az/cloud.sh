alias az-cloud-list-default="nix::az::cloud::list::default | sort"
alias az-cloud-list-custom="nix::az::cloud::list::custom | sort"
alias az-cloud-clean="nix::az::cloud::clean"

nix::az::cloud::list::default() {
    nix::bash::elements NIX_AZURE_CLOUD_BUILTIN
}

nix::az::cloud::list::custom() {
    nix::az::cloud::list \
        | sort \
        | nix::line::except <(
            nix::az::cloud::list::default \
            | sort
        )
}

nix::az::cloud::clean() {
    nix::az::cloud::list::custom \
        | pump nix::az::cloud::unregister
}

