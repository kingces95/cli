# Installation
To install the NIX shell:
1. From a [Windows](#windows) or [Mac](#mac) provision a CloudPC.
2. On the [CloudPC](#cloudpc) install Windows Subsystem for Linux (WSL2).
3. In [WSL2](#wsl2) sync `azure-devtest-center`.
4. Open the [azure-devtest-center](#azure-devtest-center) in VSCode.
5. Source [The NIX Shell](#the-nix-shell) environment `~/git/azure-devtest-center/nix/shim.sh`

Proceed through the walk-throughs in the order. 
2. [Postman](./md/postman.md) - Shared HTTP requests; Verfiy our resource provider returns the expected error message.

## Windows
```cmd
REM install az cli > follow instructions
c:\> start https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

REM test az cli installation
c:\> az --version
azure-cli                         2.35.0

REM open az fidalgo extension release page > download latest version
c:\> start https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/21260/Az-Cli
c:\> az extension add --upgrade --yes --only-show-errors --source %USERPROFILE%\downloads\fidalgo-0.3.2-py3-none-any.whl

REM login to PPE tenant with domain account (e.g. %USERNAME%@fidalgoppe010.onmicrosoft.com)
c:\> az login --tenant 8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd

REM spinup virtual machine
c:\> az fidalgo dev virtual-machine create ^
    --dev-center=nix-%USERNAME%-ppe-my-dev-center ^
    --name=nix-chrkin-ppe-my-vm --pool-name=nix-chrkin-ppe-mypool ^
    --project-name=nix-chrkin-ppe-my-project ^
    --subscription=974ae608-fbe5-429f-83ae-924a64019bf3

REM wait for virtual machine to be provisioned
c:\> az fidalgo dev virtual-machine show ^
    --dev-center=nix-chrkin-ppe-my-dev-center ^
    --name=nix-%USERNAME%-ppe-my-vm ^
    --project-name=nix-chrkin-ppe-my-project

REM click "Download Remote Desktop" > subscribe > %USERNAME%@fidalgoppe010.onmicrosoft.com
c:\> start https://deschutes-ppe.microsoft.com
```
## CloudPC
```ps
# install vscode
ps> Start-Process https://code.visualstudio.com/download

# install WSL2 and reboot
ps> Enable-WindowsOptionalFeature -online -FeatureName "Microsoft-Windows-Subsystem-Linux;VirtualMachinePlatform" -All -NoRestart; Restart-Computer

# install VsCode extension for accessing WSL2 
ps> code --install-extension ms-vscode-remote.remote-wsl

# install ubuntu
ps> wsl --install -d Ubuntu

# disable adding win PATH to Ubuntu PATH
# https://stackoverflow.com/questions/51336147/how-to-remove-the-win10s-path-from-wsl 
```
```bash
# Enter your alias as username (e.g. chrkin)
Enter new UNIX username: chrkin
Enter password:

# Check that you entered your alias
$ echo $USER
chrkin

# create keypair
$ ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

# add ado to known hosts (prevents prompting when cloning)
$ ssh-keyscan -t rsa ssh.dev.azure.com >> ~/.ssh/known_hosts

# add public key to ado; copy everything that cat emits to
# https://dev.azure.com/devdiv/_usersSettings/keys
$ cat ~/.ssh/id_rsa.pub
```
## azure-devtest-center
```bash
# clone repository
$ git clone git@ssh.dev.azure.com:v3/devdiv/OnlineServices/azure-devtest-center ~/git/azure-devtest-center

# install kusto cli
$ (cd ~/git/azure-devtest-center/nix; nuget install)
```
```bash
# open repository in vscode
$ code ~/git/azure-devtest-center/ &
# VSCode should open and in the lower left there should be a green box with the text ">< USL: Ubuntu"
```
```bash
# set default shell environment to bash
vscode > CTRL+SHIFT-P > Terminal: Select Default Profile > Select bash

# save files when the focus changes
vscode > CTRL+, > Save on focus > off -> onFocusChange

# configure useful shell keybindings
vscode > CTRL-SHIFT-P > Preferences: Open Keyboard Shortcuts (JSON) 

# Copy/Paste the below shortcuts to enable:
#   CTRL+` CTRL+` > Open/Close shell toggle
#   CTRL+` UP     > Fullscreen shell toggle
#   CTRL+SHFIT+`  > New shell
#   CTRL+` RIGHT  > Next shell
#   CTRL+` LEFT   > Previous shell
#   CTRL+` DOWN   > Run selected text in shell (super nice)
```
```json
// Place your key bindings in this file to override the defaultsauto[]
[
    {
        "key": "ctrl+` ctrl+`",
        "command": "workbench.action.terminal.toggleTerminal"
    },
    {
        "key": "ctrl+` up",
        "command": "workbench.action.toggleMaximizedPanel"
    },
    {
        "key": "ctrl+` right",
        "command": "workbench.action.terminal.focusNext"
    },
    {
        "key": "ctrl+` left",
        "command": "workbench.action.terminal.focusPrevious"
    },
    {
        "key": "ctrl+` down",
        "command": "workbench.action.terminal.runSelectedText"
    }
]
```