docker run fidalgotesting/devcontainer:v0.0.3 --privileged
apt install -y gh
GITHUB_USER=kingces95
gh auth login
sudo mkdir workspaces
chmod a+rw workspaces/
cd workspaces/
gh repo clone Azure/fidalgo-dev
chmod a+rwx sshd-debian.sh
sudo ./sshd-debian.sh 
/usr/local/share/ssh-init.sh
