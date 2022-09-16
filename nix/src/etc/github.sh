nix::github::pr::create() {
    gh pr create --fill
}

nix::github::pr::merge() {
    gh pr merge \
        --squash \
        --delete-branch
}
