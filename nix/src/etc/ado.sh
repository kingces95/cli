nix::ado::configure() {  
    az devops configure \
        --defaults \
            organization=https://dev.azure.com/devdiv \
            project=OnlineServices
}
