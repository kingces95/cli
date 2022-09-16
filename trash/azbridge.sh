cd /workspaces
gh repo clone kingces95/azure-relay-bridge-binaries
cd azure-relay-bridge-binaries/
sudo apt-get install -y ./azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb

# https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/3de261df-f2d8-4c00-a0ee-a0be30f1e48e/resourceGroups/dev/providers/Microsoft.Relay/namespaces/fidalgo/overview
ENDPOINT="sb://fidalgo.servicebus.windows.net/"
SHARED_ACCESS_KEY_NAME="RootManageSharedAccessKey"
SHARED_ACCESS_KEY="Hx5Io+2cVliAy4bJbEObF0fBKu14VyidtV1DoS230pA="

. /etc/profile.d/azbridge.sh
cat /etc/hosts
addhost 127.1.2.4 ssh.corp.example.com

# client
azbridge -L 127.1.2.4:2223:dogfood  \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}"

# server
azbridge -R dogfood:localhost:2223/2222 \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}"

# https://github.community/t/will-it-be-possible-to-create-an-ssh-tunnel-to-a-codespaces-instance/130823/5
SSH_SCRIPT=https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/sshd-debian.sh
curl -sSL "${SSH_SCRIPT}" | sudo bash -s -- 2222 $(whoami) true random
cat /etc/ssh/sshd_config | grep 2222

# start ssh server on port 2222
/usr/local/share/ssh-init.sh
echo "vscode:password" | sudo chpasswd

# direct connect to ssh server
ssh \
    -p 2222 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    vscode@localhost

# relay connection to ssh server
ssh \
    -p 2223 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    vscode@127.1.2.4
    

DATAPLANE_HOST=nix-chrkin-df-19-my-dev-center.devcenters.fidalgo.azure-test.net
DATAPLANE_PORT=443
HTTPS_PORT=443

addhost 127.1.2.5 nix-chrkin-df-19-my-dev-center.devcenters.fidalgo.azure-test.net

# client
azbridge -L 127.1.2.5:"${DATAPLANE_PORT}":dataplane  \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}"

# server
azbridge -R dataplane:localhost:${DATAPLANE_PORT}/${HTTPS_PORT} \
    -e "${ENDPOINT}" \
    -K "${SHARED_ACCESS_KEY_NAME}" \
    -k "${SHARED_ACCESS_KEY}"    
