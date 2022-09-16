
# The NIX Shell
The nix shell is a collection of aliases, variables. 
## Aliases
Aliases constitute the public surface area of the nix. 
```bash
[PUBLIC] $ alias        # list all aliases
[PUBLIC] $ fd-          # auto-complete; hit tab twice to list aliases
```
## Variables
```bash
[PUBLIC] $ fd-nix       # dump variables prefixed with NIX_
```
## Reflection
Enter `fd-who` to see environment variables that establish your current Fidalgo identity.
```bash
[PUBLIC] $ fd-who
az    user            chrkin@microsoft.com                                           
az    user-id         55704deb-7b32-49c8-9b61-ab5dec3616cd                           
az    subscription    Project Fidalgo - VDI Dogfooding                               
az    subscription-id 0db9eb1b-4884-4027-9ad5-fea398c784c4                           
az    tenant-id       72f988bf-86f1-41af-91ab-2d7cd011db47                           
az    cloud           AzureCloud                                                     
env   fid             PUBLIC                                                         
env   cpc             PUBLIC                                                         
env   as              administrator                                                  
env   cli                                                                            
kusto token-url       https://help.kusto.windows.net                                 
kusto data-source     https://fidalgopublic.westus2.kusto.windows.net/               
kusto initial-catalog devceneter-public                                                 
me    name            chrkin                                                         
me    profile         /home/chrkin/git/azure-devtest-center/nix/usr/chrkin/.profile.s
me    env-id          0   
```

## Accounts
You  need the following accounts. The team should have already created a set of **default** accounts for you. The others you will create next.

| Environment | Default | Type | Upn (example) | Admin | MFAx |
| - | - | - | - | - | - |
| public | x | domain | chrkin@microsoft.com |
| dogfood | x | domain | chrkin@microsoft.com | x
| dogfood-int | x | domain | chrkin@microsoft.com | x
| self-host | x | guest | chrkin@microsoft.com | x
| self-host | | domain | chrkin-admin@fidalgosh010.onmicrosoft.com | x | x
| self-host | x | domain | chrkin@fidalgosh010.onmicrosoft.com | | x
| ppe | x | guest | chrkin@microsoft.com | x
| ppe | | domain | chrkin-admin@fidalgoppe010.onmicrosoft.com | x | x
| ppe | x | domain | chrkin@fidalgoppe010.onmicrosoft.com | | x
| int | x | guest | chrkin@microsoft.com | x
| int | | domain | chrkin-admin@fidalgobeta.onmicrosoft.com | x | x
| int | x | domain | chrkin@fidalgobeta.onmicrosoft.com | | x

- None of the accounts have multi-factor authentication (MFA) disabled by default. We will disable MFA where possible by adding accounts to the `MFA Excluded Users` (MFAx) group. 

- You will be prompted to authenticate multipule times during this flow. Each time login with your microsoft account (e.g. chrkin@microsoft.com). 

- After compleating this flow, the environment will use the shared team secret you entered earlier to silently authenticate as you switch between environments.

```bash
[PUBLIC] $ fd-switch-to-selfhost-as-me      # login using guest account (e.g. chrkin@microsoft.com)
[SELFHOST me] $ fd-user-list                # you should have one user
chrkin@fidalgoppe010.onmicrosoft.com        # this is your domain user

# dsiable 2FA for your self-host domain user
[SELFHOST me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"  

# create administrator account
[SELFHOST me] $ fd-user-create 'admin'
[SELFHOST me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[SELFHOST me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"

# verify your accounts
[SELFHOST me] $ fd-user-report | a2f  
chrkin-admin@fidalgosh010.onmicrosoft.com MFA-Excluded-Users Admins
chrkin@fidalgosh010.onmicrosoft.com       MFA-Excluded-Users  

# repeat for PPE
[SELFHOST me] $ fd-switch-to-ppe-as-me      # login using guest account (e.g. chrkin@microsoft.com)
[PPE me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"
[PPE me] $ fd-user-create 'admin'
[PPE me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[PPE me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[PPE me] $ fd-user-report | a2f  

# repeat for INT
[PPE me] $ fd-switch-to-int-as-me           # login using guest account (e.g. chrkin@microsoft.com)
[INT me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"
[INT me] $ fd-user-create 'admin'
[INT me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[INT me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[INT me] $ fd-user-report | a2f

 # return to public
[INT me] $ fd-switch-to-public
[PUBLIC] $
```
## Environments
There are 5 **environments**. 
- Each environment is associated with a single Azure **tenant**.
- Each tenant exists in an Azure **cloud** (a collection of url endpoints). 
- The two clouds we use are **AzureCloud** and **Dogfood**. 
- See the tenants associated with AzureCloud [here](https://portal.azure.com/#settings/directory) and with Dogfood cloud [here](https://df.onecloud.azure-test.net ). 
  - Enter `fd-nix-env-www` to see other portals associated with the environment.
- Each environment contains azure resources that run 
  - **Fidalgo services** `dev-center`, `network-setting`, `pool`, etc
  - **CloudPC services** `virtual-network`, `subnet`, `vm`, etc
- All environmnts run both Fidalgo and CloudPC services in the same environment except dogfood. 
  - Dogfood hosts CloudPC services in selfhost or int.

| Fidalgo | CloudPC | Cloud | Tenant | Description |
| - | - | - | - | - |
| public    | public    | AzureCloud | 72f988bf-86f1-41af-91ab-2d7cd011db47 | No testing. |
| dogfood   | selfhost  | Dogfood    | f686d426-8d16-42db-81b7-ab578e110ccd | Developer testing of Fidalgo services. |
| dogfood-int   | int  | Dogfood    | f686d426-8d16-42db-81b7-ab578e110ccd | Developer testing of Fidalgo services. |
| selfhost  | selfhost    | AzureCloud | 003b06c3-d471-4452-9686-9e7f3ca85f0a | Supports developer testing in dogfood by hosting CloudPC resources. |
| ppe       | ppe    | AzureCloud | 8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd | Integration testing. |
| n/a       | int    | AzureCloud | eb457173-3dfd-4145-bd18-68e25e0a10fa | Strictly dogfood backing. |
```bash
[PUBLIC] $ fd-switch-to-ppe                 # switch to ppe
[PPE] $ fd-who                              # reflect on ppe identity
[PPE] $ fd-switch-to-public                 # switch back to public
[PUBLIC] $ fd-login
```

## Personas
Each environment supports 5 personas. 

- Use the `fd-login-as-` family of commands to login as different personas within in an environment.

| Persona | Command | Description |
| - | - | - |
| me                    | `fd-login-as-me`                    | Used to create accounts for the other personas.
| administrator         | `fd-login`                          | Used to execute `az fidalgo admin` family of commands.
| developer             | `fd-login-as-developer`             | Used to execute `az fidalgo dev` family of commands.
| network-administrator | `fd-login-as-network-administrator` | Used to execute `az` commands to create dependent resources (e.g. `virtual-network`/`subnet`).
| vm-user               | `fd-login-as-vm-user`               | User assigned to own a CloudPC.

```bash
[PUBLIC] $ fd-login-as-developer            # administrator persona is the default 
[PUBLIC developer] $ fd-who                 # reflect on developer persona
[PUBLIC developer] $ fd-login               # developer persona
[PUBLIC] $ fd-login                         # switch back to administrator persona
```

## Environments x Personas x Accounts
Environments map personas with accounts.

| Environment | Persona | User Principal Name (example) | Switch
| - | - | - | - |
| public        | all                   | chrkin@microsoft.com                          | `fd-switch-to-public`
| ppe           | administrator         | chrkin-admin@fidalgoppe010.onmicrosoft.com    | `fd-switch-to-ppe`
| ppe           | developer, vm-user    | chrkin@fidalgoppe010.onmicrosoft.com          |
| ppe           | network-administrator | chrkin-admin@fidalgoppe010.onmicrosoft.com    | 
| int           | administrator         | chrkin-admin@fidalgobeta010.onmicrosoft.com   | `fd-switch-to-int`
| int           | developer, vm-user    | chrkin@fidalgobeta010.onmicrosoft.com         |
| int           | network-administrator | chrkin-admin@fidalgobeta010.onmicrosoft.com   | 
| selfhost      | administrator         | chrkin-admin@fidalgosh010.onmicrosoft.com     | `fd-switch-to-selfhost`
| selfhost      | developer, vm-user    | chrkin@fidalgosh010.onmicrosoft.com           | 
| selfhost      | network-administrator | chrkin-admin@fidalgosh010.onmicrosoft.com     | 
| dogfood       | administrator         | chrkin@microsoft.com                          | `fd-switch-to-dogfood`
| dogfood       | developer             | chrkin@microsoft.com                          |
| dogfood       | vm-user               | chrkin@fidalgosh010.onmicrosoft.com           |
| dogfood       | network-administrator | chrkin-admin@fidalgosh010.onmicrosoft.com     |
| dogfood-int   | administrator         | chrkin@microsoft.com                          | `fd-switch-to-dogfood-int`
| dogfood-int   | developer             | chrkin@microsoft.com                          |
| dogfood-int   | vm-user               | chrkin@fidalgobeta010.onmicrosoft.com         |
| dogfood-int   | network-administrator | chrkin-admin@fidalgobeta010.onmicrosoft.com   |
## Networking
Next you will setup a virtual network in each environment which you will reuse during tesing. 

- Each netwok will 
  - be peered to the domain controller for the environment.
  - use the domain controller as a DNS server.
  - use the IP block allocated to you above during profile initialization.

```bash
[PUBLIC] $ ppe
[PPE] $ fd-login-as-network-administrator
[PPE network-administrator] $ 
```
Next, follow [this](./tst/sh/my-vnet.sh) flow to create your virtual network.
```bash
# repeat for selfhost and int environments
[PPE network-administrator] $ selfhost
[SELFHOST network-administrator] $ int
[INT network-administrator] $ 
```

# Kusto

```bash
# test kusto authentication
[PUBLIC] $ dri-                             # hit tab twice to get listing            
[PUBLIC] $ dri-certificate-loaded           # see kusto query
[PUBLIC] $ dri-certificate-loaded | kusto   # execute kusto query against public
[PUBLIC] $ fd-switch-to-dogfood             # switch to dogfood
[DOGFOOD] $ dri-certificate-loaded | kusto  # execute kusto query against dogfood
```
