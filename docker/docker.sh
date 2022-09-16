alias fd-docker-reload=". $(readlink -f ${BASH_SOURCE})"
alias fd-docker-build="nix::docker::main"
alias fd-docker-package="nix::docker::buildx::tar"
alias fd-docker-buildx="nix::docker::buildx::build"
alias fd-docker-hub-login="nix::docker::hub::login"
alias fd-docker-hub-publish="nix::docker::hub::publish"

# https://hub.docker.com/repository/docker/fidalgotesting
# https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker-in-docker.md
# https://superuser.com/questions/1401919/cannot-start-docker-when-using-chroot

declare NIX_DOCKERHUB_USER='fidalgotesting'
declare NIX_DOCKERHUB_PASSWORD="${NIX_CODESPACE_SECRET_AZURE_PASSWORD}"

declare NIX_DOCKER_BUILDX_INSTANCE=insecure-builder

declare NIX_DOCKER_USER='vscode'
declare NIX_DOCKER_PREBUILD_VARIANT='jammy'
declare NIX_DOCKER_PREBUILD_IMAGE='mcr.microsoft.com/vscode/devcontainers/base:0'
declare NIX_DOCKER_PREBUILD_TOOLS='debootstrap'
declare NIX_DOCKER_CHROOT_SUITE='focal'
declare NIX_DOCKER_CHROOT_TAG='devcontainer'
declare NIX_DOCKER_CHROOT_VERSION='v0.0.8'
declare NIX_DOCKER_CHROOT_FULLNAME="${NIX_DOCKERHUB_USER}/${NIX_DOCKER_CHROOT_TAG}:${NIX_DOCKER_CHROOT_VERSION}"

nix::docker::main() {
    nix::docker::buildx::tar
    nix::docker::buildx::build
    nix::docker::hub::login
    nix::docker::hub::publish
}

nix::docker::buildx::instance::test() {
    docker buildx ls \
        | grep "${NIX_DOCKER_BUILDX_INSTANCE}" \
        >/dev/null 2>/dev/null
}

nix::docker::buildx::instance::create() {
    if nix::docker::buildx::instance::test; then
        return
    fi

    docker buildx create \
        --driver-opt image=moby/buildkit:master \
        --use \
        --name "${NIX_DOCKER_BUILDX_INSTANCE}" \
        --buildkitd-flags "--allow-insecure-entitlement security.insecure"

}

nix::docker::buildx::instance::remove() {
    docker buildx rm "${NIX_DOCKER_BUILDX_INSTANCE}"
}

nix::docker::buildx::tar() {
    local TARBALL=fidalgo-dev.tar.gz

    if [[ -f "${TARBALL}" ]]; then
        sudo rm "${TARBALL}"
    fi

    tar \
        -C '/workspaces/fidalgo-dev/' \
        -cf "/tmp/${TARBALL}" \
        . \
        >/dev/null 

    cp "/tmp/${TARBALL}" .
}

nix::docker::buildx::build() {
    local TARBALL=fidalgo-dev.tar.gz

    nix::docker::buildx::instance::create

    docker buildx use "${NIX_DOCKER_BUILDX_INSTANCE}"

    if [[ ! -f "${TARBALL}" ]]; then
        nix::docker::buildx::tar
    fi

    docker buildx build --allow security.insecure . \
        --progress=plain \
        --build-arg VARIANT="${NIX_DOCKER_PREBUILD_VARIANT}" \
        --build-arg IMAGE="${NIX_DOCKER_PREBUILD_IMAGE}" \
        --build-arg TOOLS="${NIX_DOCKER_PREBUILD_TOOLS}" \
        --build-arg USER="${NIX_DOCKER_USER}" \
        --build-arg TARBALL="${TARBALL}" \
        --tag "${NIX_DOCKER_CHROOT_FULLNAME}" \
        --output "type=docker"
}

nix::docker::hub::login() {
    docker login \
        --username "${NIX_DOCKERHUB_USER}" \
        --password-stdin \
        <<< "${NIX_DOCKERHUB_PASSWORD}"
}

nix::docker::hub::publish() {
    nix::docker::hub::login
    docker push "${NIX_DOCKER_CHROOT_FULLNAME}"
}
