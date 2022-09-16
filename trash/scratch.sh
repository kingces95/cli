# https://unix.stackexchange.com/questions/708066/subprocess-launched-inside-a-chroot-created-on-a-codespace-with-debootstrap-fail
sudo apt-get install -y binutils debootstrap

declare -g NIX_CHROOT="${HOME}/chroot-ubuntu"
mkdir "${NIX_CHROOT}"

time sudo debootstrap --make-tarball=/tmp/focal.tgz focal "${NIX_CHROOT}"       # real    1m32.023s
time sudo debootstrap --unpack-tarball=/tmp/focal.tgz focal "${NIX_CHROOT}"     # real    3m34.842s

declare -g NIX_CHROOT_FOREIGN="${HOME}/chroot-ubuntu-foreign"
sudo debootstrap --foreign focal "${NIX_CHROOT_FOREIGN}"

declare -g NIX_CHROOT="${HOME}/chroot"
# mkdir "${NIX_CHROOT}"

NIX_DEBOOTSTRAP_SUITE=jammy
NIX_CHROOT_TARBALL="${HOME}/debootstrap-${NIX_DEBOOTSTRAP_SUITE}.tgz"

time sudo debootstrap \
    --make-tarball=${NIX_CHROOT_TARBALL} \
    ${NIX_DEBOOTSTRAP_SUITE} \
    "${NIX_CHROOT}"
time sudo debootstrap \
    --unpack-tarball=${NIX_CHROOT_TARBALL} \
    ${NIX_DEBOOTSTRAP_SUITE} \
    "${NIX_CHROOT}"

time sudo debootstrap focal "${NIX_CHROOT}" # real    5m43.056s

sudo cp -pr "${NIX_CHROOT_UNPACKED}" "${NIX_CHROOT}" 

sudo umount "${NIX_CHROOT}/proc/"
sudo umount "${NIX_CHROOT}/dev/"
sudo umount "${NIX_CHROOT}/workspaces/"
sudo umount "${NIX_CHROOT}/sys/"
sudo umount "${NIX_CHROOT}/tmp/"
sudo umount "${NIX_CHROOT}/sys/fs/cgroup"
sudo umount "${NIX_CHROOT}/sys/kernel/security"
mount -l | grep chroot
# sudo rm -r -f "${NIX_CHROOT}"

sudo mkdir -p "${NIX_CHROOT}/workspaces/"
sudo mount --bind "/workspaces/" "${NIX_CHROOT}/workspaces/"
sudo mount --bind "/proc/" "${NIX_CHROOT}/proc/"
sudo mount --bind "/dev/" "${NIX_CHROOT}/dev/"
sudo mount --bind "/sys/" "${NIX_CHROOT}/sys/"
mount -l | grep chroot

sudo chroot "${NIX_CHROOT}"

sudo apt-get install -y software-properties-common >/dev/null
sudo add-apt-repository -y universe >/dev/null
sudo add-apt-repository -y multiverse >/dev/null

# Fix 'Temporary failure in name resolution'
echo "127.0.0.1 $HOSTNAME" \
    | sudo tee -a /etc/hosts >/dev/null

cat /etc/locale.gen \
    | sed 's/# en_US.UTF-8/en_US.UTF-8/g' \
    | sudo tee /tmp/locale.gen >/dev/null
sudo cp /tmp/locale.gen /etc/locale.gen
sudo locale-gen

# sudo apt install -y curl

GITHUB_USER=kingces95
USER=codespace
cd workspaces/fidalgo-dev/
. shim.sh

nix::bridge() {
    sudo debootstrap stable "${NIX_CHROOT}" http://deb.debian.org/debian/
    sudo mount -i -o remount,exec,dev /workspaces/

# init
    NIX_CHROOT="${HOME}/chroot"
    sudo cp "/etc/init.d/ssh" "${NIX_CHROOT}/etc/init.d/ssh"
    sudo mount --bind "/etc/ssh/" "${NIX_CHROOT}/etc/ssh/"
    sudo mount --bind "/home/anon/.ssh/" "${NIX_CHROOT}/home/anon/.ssh/"

# alt
    sudo mount -t proc /proc chroot-ubuntu/proc
    sudo mount --rbind /sys chroot-ubuntu/sys
    sudo mount --rbind /dev chroot-ubuntu/dev

# remove
    sudo umount "${NIX_CHROOT}/workspaces/"
    sudo umount "${NIX_CHROOT}/etc/ssh/"
    sudo umount "${NIX_CHROOT}/etc/init.d/ssh/"
    sudo rm -r -f "${NIX_CHROOT}"

# enter
    NIX_CHROOT="${HOME}/chroot-ubuntu"
    sudo chroot "${NIX_CHROOT}"

    chown root /

    echo "127.0.0.1 $HOSTNAME" \
        | sudo tee -a /etc/hosts >/dev/null
    cat /etc/locale.gen \
        | sed 's/# en_US.UTF-8/en_US.UTF-8/g' \
        | sudo tee /etc/locale.gen >/dev/null
    sudo locale-gen

    # apt install sudo
    sudo apt update
    sudo apt install -y git
    sudo apt-get install -y curl
    sudo apt-get install -y nano
    sudo apt-get install -y man
    sudo apt-get install -y net-tools
    sudo apt-get install -y openssh-server
    sudo apt-get install -y apt-transport-https software-properties-common

    CODESPACE_VSCODE_FOLDER=/workspaces/virtual-private-tunnel
    cd "${CODESPACE_VSCODE_FOLDER}"

    . shim.sh
    nix::tool::az::install
    nix::tool::nc::install
    nix::tool::azbridge::install

    sudo systemctl enable ssh
}

MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"
architecture="$(dpkg --print-architecture)"

curl -sSL ${MICROSOFT_GPG_KEYS_URI} \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg \
    > /dev/null
echo "deb ["\
        "arch=${architecture}" \
        "signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg" \
    "] https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_CODENAME}-prod" \
    "${VERSION_CODENAME} main" \
    > /etc/apt/sources.list.d/microsoft.list

sudo apt-get install \
    -y --no-install-recommends \
    moby-cli \
    moby-buildx \
    moby-engine


###############

NIX_DIR_CHROOT=/tmp/stable_root
mkdir -p $NIX_DIR_CHROOT
mkdir -p $NIX_DIR_CHROOT/{bin,lib,lib64}
cd $NIX_DIR_CHROOT
cp -v /bin/{bash,touch,ls,rm} $NIX_DIR_CHROOT/bin
ldd /bin/bash

nix::lld() {
    local PTH="$1"
    shift
    
    ldd "${PTH}" \
        | egrep -o '/lib.*\.[0-9]'
}

nix::lld::cp() {
    local PTH="$1"
    shift
    
    local TARGET="$NIX_DIR_CHROOT"
    shift

    while read -r; do
        cp -v --parents \
            "${REPLY}" \
            "${TARGET}"
    done < <(
        echo "${PTH}"
        nix::lld "${PTH}"
    )
}

nix::cp::parent() {
    cp -v --parents "$1" "$NIX_DIR_CHROOT"
}

nix::lld::cp /bin/bash
nix::lld::cp /bin/touch
nix::lld::cp /bin/ls
nix::lld::cp /bin/rm
nix::lld::cp /bin/find
nix::lld::cp /usr/bin/apt

nix::cp::parent \
    ./usr/lib/x86_64-linux-gnu/libgcrypt.so.20

cp -v --parents \
    /etc/apt/apt.conf.d/* \
    $NIX_DIR_CHROOT

cp -v --parents \
    /etc/resolv.conf \
    $NIX_DIR_CHROOT

sudo chroot $NIX_DIR_CHROOT /bin/bash

touch sample_file.txt
ls
rm sample_file.txt
ls

NIX_DIR_CHROOT=/workspaces/chroot

# https://superuser.com/questions/620003/debootstrap-error-in-ubuntu-13-04-raring
sudo mount -i -o remount,exec,dev /workspaces/
nix::chroot::install() {
    sudo apt-get install -y binutils debootstrap
    mkdir "${NIX_DIR_CHROOT}"
    
    sudo debootstrap stable "${NIX_DIR_CHROOT}" http://deb.debian.org/debian/
}
nix::chroot::install

nix::chroot::cp() {
    cp -v --parents "$1" "${NIX_DIR_CHROOT}/"
}

mkdir -p "${NIX_DIR_CHROOT}/workspaces/fidalgo-dev"
sudo mount --bind "/workspaces/fidalgo-dev/" "${NIX_DIR_CHROOT}/workspaces/fidalgo-dev/"
sudo mount --bind "/proc/" "${NIX_DIR_CHROOT}/proc/"

sudo cp -v /home/codespace/.profile /workspaces/chroot/root/
sudo cp -v /home/codespace/.bashrc /workspaces/chroot/root/

sudo chroot $NIX_DIR_CHROOT
apt install sudo
sudo apt update
sudo apt install -y git
cd /workspaces/fidalgo-dev
USER=codespace
GITHUB_USER=kingces95

# https://www.funtoo.org/Talk:Install/Chroot
# Probably should be included in the funtoo handbook?
# EDIT: Command used for chroot was "sudo chroot /mnt/funtoo /bin/bash"
# -Kreyren (talk) 07:45, January 28, 2019 (UTC)

# Same issue, and can be resolved via changing 'mount --rbind /sys sys' to 'mount --rbind /sys /mnt/funtoo/sys'. Same method apply with '/dev' directory.
# -Jeon (talk) April 15, 2021 (UTC)

cd /workspaces
gh repo clone kingces95/azure-relay-bridge-binaries
cd azure-relay-bridge-binaries/
sudo apt-get install ./azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb
. /etc/profile.d/azbridge.sh
cat /etc/hosts
addhost 127.1.2.3 sql.corp.example.com
addhost 127.1.2.4 ssh.corp.example.com

cat /etc/hosts
azbridge -L 127.1.2.3:1433:sql-corp-example-com

ENDPOINT="sb://chrkin.servicebus.windows.net/"
SHARED_ACCESS_KEY_NAME="RootManageSharedAccessKey"
SHARED_ACCESS_KEY="6UalWH2tcyRTNyrGJRbRwWGbi78frVfm8qt93NzI6xs="
CONNECTIONSTRING="Endpoint=sb://chrkin.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=6UalWH2tcyRTNyrGJRbRwWGbi78frVfm8qt93NzI6xs="

azbridge -L 127.1.2.4:2223:codespace  \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}" \
    -vvv

azbridge -R codespace:localhost:2223/2222 \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}"

azbridge -R ssh-corp-example-com:localhost:2223/2222 \
    -x "${CONNECTIONSTRING}" \
    -vvv

https://chrkin.servicebus.windows.net/codespace

Endpoint=sb://chrkin.servicebus.windows.net/;
    SharedAccessKeyName=RootManageSharedAccessKey;
    SharedAccessKey=***=
-E (Endpoint) # e
-K (SharedAccessKeyName)
-k (SharedAccessKey)
-S (SharedAccessSignature)

# https://portal.azure.com/#@fidalgoppe010.onmicrosoft.com/resource/subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/chrkin-rg/providers/Microsoft.Relay/namespaces/chrkin/saskey

SSH_SCRIPT=https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/sshd-debian.sh
curl -sSL "${SSH_SCRIPT}" | sudo bash -s -- 2222 $(whoami) true random

cat /usr/local/share/ssh-init.sh
https://github.community/t/will-it-be-possible-to-create-an-ssh-tunnel-to-a-codespaces-instance/130823/5
2222
codespace
219dfdd96974c9ef3f17be3e667b329a

echo "codespace:password" | sudo chpasswd

ssh \
    -p 2222 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    codespace@localhost

ssh \
    -p 2223 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    codespace@127.1.2.4

##################

mkdir -p $HOME/release \
    && curl -SL https://github.com/kingces95/codespace-container/archive/refs/tags/0.0.0.tar.gz \
        | tar -xzC $HOME/release

sudo passwd root
su root

sudo mount --bind ./foo/ ./bar/

mount -o remount,rw /
mount --all
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo
restart


######################
