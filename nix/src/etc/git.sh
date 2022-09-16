nix::git::branch() {
    local BRANCH="$1"
    shift

    git checkout -b "${BRANCH}"
}

nix::git::checkout() {
    local BRANCH="$1"
    shift

    git checkout "${BRANCH}"
}

nix::git::branch::delete() {
    local BRANCH="$1"
    shift

    git branch -D "${BRANCH}"
}

nix::git::commit() {
    local TITLE="$1"
    shift

    local FILES=()
    mapfile -t FILES
    
    git add "${FILES[@]}"
    git commit --message "${TITLE}"
}

nix::git::push() {
    local BRANCH="$(git branch --show-current)"
    git push --set-upstream origin "${BRANCH}"
}

nix::git::pull() {
    git pull
}
