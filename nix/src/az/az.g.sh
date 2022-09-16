alias az-account-get-access-token="nix::az::account::get_access_token"
alias az-account-list-default="nix::az::account::list::default"
alias az-account-list="nix::az::account::list"
alias az-account-set="nix::az::account::set"
alias az-account-show-subscription-id="nix::az::account::show::subscription::id"
alias az-account-show-subscription-name="nix::az::account::show::subscription::name"
alias az-account-show-tenant-id="nix::az::account::show::tenant::id"
alias az-account-show="nix::az::account::show"
alias az-account-tenant-list="nix::az::account::tenant::list"
alias az-account="nix::az::account"
alias az-acount-location-list="nix::az::acount::location::list"
alias az-ad-group-member-add="nix::az::ad::group::member::add"
alias az-ad-group-member-check="nix::az::ad::group::member::check"
alias az-ad-group-member-list="nix::az::ad::group::member::list"
alias az-ad-group-member-remove="nix::az::ad::group::member::remove"
alias az-ad-group-member="nix::az::ad::group::member"
alias az-ad-group="nix::az::ad::group"
alias az-ad-sp-id="nix::az::ad::sp::id"
alias az-ad-sp="nix::az::ad::sp"
alias az-ad-user-create="nix::az::ad::user::create"
alias az-ad-user-delete="nix::az::ad::user::delete"
alias az-ad-user-filter="nix::az::ad::user::filter"
alias az-ad-user-get-member-groups="nix::az::ad::user::get_member_groups"
alias az-ad-user-id="nix::az::ad::user::id"
alias az-ad-user="nix::az::ad::user"
alias az-ad="nix::az::ad"
alias az-cloud-list="nix::az::cloud::list"
alias az-cloud-register="nix::az::cloud::register"
alias az-cloud-set="nix::az::cloud::set"
alias az-cloud-show="nix::az::cloud::show"
alias az-cloud-unregister="nix::az::cloud::unregister"
alias az-cloud-which="nix::az::cloud::which"
alias az-cloud="nix::az::cloud"
alias az-extension-list="nix::az::extension::list"
alias az-extension-remove="nix::az::extension::remove"
alias az-extension-upgrade-source="nix::az::extension::upgrade::source"
alias az-extension-upgrade="nix::az::extension::upgrade"
alias az-extension-which="nix::az::extension::which"
alias az-extension="nix::az::extension"
alias az-group-delete="nix::az::group::delete"
alias az-group="nix::az::group"
alias az-keyvault-secret-id="nix::az::keyvault::secret::id"
alias az-keyvault-secret="nix::az::keyvault::secret"
alias az-keyvault="nix::az::keyvault"
alias az-login-with-device-code="nix::az::login::with_device_code"
alias az-login-with-secret="nix::az::login::with_secret"
alias az-login="nix::az::login"
alias az-logout="nix::az::logout"
alias az-network-vnet-dns="nix::az::network::vnet::dns"
alias az-network-vnet-list="nix::az::network::vnet::list"
alias az-network-vnet-location="nix::az::network::vnet::location"
alias az-network-vnet-show="nix::az::network::vnet::show"
alias az-network-vnet-subnet-address-prefix="nix::az::network::vnet::subnet::address_prefix"
alias az-network-vnet-subnet-delegation="nix::az::network::vnet::subnet::delegation"
alias az-network-vnet-subnet-list="nix::az::network::vnet::subnet::list"
alias az-network-vnet-subnet-show="nix::az::network::vnet::subnet::show"
alias az-network-vnet-subnet="nix::az::network::vnet::subnet"
alias az-network-vnet="nix::az::network::vnet"
alias az-network="nix::az::network"
alias az-query="nix::az::query"
alias az-resource-create="nix::az::resource::create"
alias az-resource-delete="nix::az::resource::delete"
alias az-resource-set="nix::az::resource::set"
alias az-resource="nix::az::resource"
alias az-role-assignment-create="nix::az::role::assignment::create"
alias az-role-assignment="nix::az::role::assignment"
alias az-role="nix::az::role"
alias az-signed-in-user-id="nix::az::signed_in_user::id"
alias az-signed-in-user-show="nix::az::signed_in_user::show"
alias az-signed-in-user-upn="nix::az::signed_in_user::upn"
nix::az::account() { nix::azure::cmd::account "$@" | nix::cmd::run; }
nix::az::account::get_access_token() { nix::azure::cmd::account::get_access_token "$@" | nix::cmd::run; }
nix::az::account::list() { nix::azure::cmd::account::list "$@" | nix::cmd::run; }
nix::az::account::list::default() { nix::azure::cmd::account::list::default "$@" | nix::cmd::run; }
nix::az::account::set() { nix::azure::cmd::account::set "$@" | nix::cmd::run; }
nix::az::account::show() { nix::azure::cmd::account::show "$@" | nix::cmd::run; }
nix::az::account::show::subscription::id() { nix::azure::cmd::account::show::subscription::id "$@" | nix::cmd::run; }
nix::az::account::show::subscription::name() { nix::azure::cmd::account::show::subscription::name "$@" | nix::cmd::run; }
nix::az::account::show::tenant::id() { nix::azure::cmd::account::show::tenant::id "$@" | nix::cmd::run; }
nix::az::account::tenant::list() { nix::azure::cmd::account::tenant::list "$@" | nix::cmd::run; }
nix::az::acount::location::list() { nix::azure::cmd::acount::location::list "$@" | nix::cmd::run; }
nix::az::ad() { nix::azure::cmd::ad "$@" | nix::cmd::run; }
nix::az::ad::group() { nix::azure::cmd::ad::group "$@" | nix::cmd::run; }
nix::az::ad::group::member() { nix::azure::cmd::ad::group::member "$@" | nix::cmd::run; }
nix::az::ad::group::member::add() { nix::azure::cmd::ad::group::member::add "$@" | nix::cmd::run; }
nix::az::ad::group::member::check() { nix::azure::cmd::ad::group::member::check "$@" | nix::cmd::run; }
nix::az::ad::group::member::list() { nix::azure::cmd::ad::group::member::list "$@" | nix::cmd::run; }
nix::az::ad::group::member::remove() { nix::azure::cmd::ad::group::member::remove "$@" | nix::cmd::run; }
nix::az::ad::sp() { nix::azure::cmd::ad::sp "$@" | nix::cmd::run; }
nix::az::ad::sp::id() { nix::azure::cmd::ad::sp::id "$@" | nix::cmd::run; }
nix::az::ad::user() { nix::azure::cmd::ad::user "$@" | nix::cmd::run; }
nix::az::ad::user::create() { nix::azure::cmd::ad::user::create "$@" | nix::cmd::run; }
nix::az::ad::user::delete() { nix::azure::cmd::ad::user::delete "$@" | nix::cmd::run; }
nix::az::ad::user::filter() { nix::azure::cmd::ad::user::filter "$@" | nix::cmd::run; }
nix::az::ad::user::get_member_groups() { nix::azure::cmd::ad::user::get_member_groups "$@" | nix::cmd::run; }
nix::az::ad::user::id() { nix::azure::cmd::ad::user::id "$@" | nix::cmd::run; }
nix::az::cloud() { nix::azure::cmd::cloud "$@" | nix::cmd::run; }
nix::az::cloud::list() { nix::azure::cmd::cloud::list "$@" | nix::cmd::run; }
nix::az::cloud::register() { nix::azure::cmd::cloud::register "$@" | nix::cmd::run; }
nix::az::cloud::set() { nix::azure::cmd::cloud::set "$@" | nix::cmd::run; }
nix::az::cloud::show() { nix::azure::cmd::cloud::show "$@" | nix::cmd::run; }
nix::az::cloud::unregister() { nix::azure::cmd::cloud::unregister "$@" | nix::cmd::run; }
nix::az::cloud::which() { nix::azure::cmd::cloud::which "$@" | nix::cmd::run; }
nix::az::extension() { nix::azure::cmd::extension "$@" | nix::cmd::run; }
nix::az::extension::list() { nix::azure::cmd::extension::list "$@" | nix::cmd::run; }
nix::az::extension::remove() { nix::azure::cmd::extension::remove "$@" | nix::cmd::run; }
nix::az::extension::upgrade() { nix::azure::cmd::extension::upgrade "$@" | nix::cmd::run; }
nix::az::extension::upgrade::source() { nix::azure::cmd::extension::upgrade::source "$@" | nix::cmd::run; }
nix::az::extension::which() { nix::azure::cmd::extension::which "$@" | nix::cmd::run; }
nix::az::group() { nix::azure::cmd::group "$@" | nix::cmd::run; }
nix::az::group::delete() { nix::azure::cmd::group::delete "$@" | nix::cmd::run; }
nix::az::keyvault() { nix::azure::cmd::keyvault "$@" | nix::cmd::run; }
nix::az::keyvault::secret() { nix::azure::cmd::keyvault::secret "$@" | nix::cmd::run; }
nix::az::keyvault::secret::id() { nix::azure::cmd::keyvault::secret::id "$@" | nix::cmd::run; }
nix::az::login() { nix::azure::cmd::login "$@" | nix::cmd::run; }
nix::az::login::with_device_code() { nix::azure::cmd::login::with_device_code "$@" | nix::cmd::run; }
nix::az::login::with_secret() { nix::azure::cmd::login::with_secret "$@" | nix::cmd::run; }
nix::az::logout() { nix::azure::cmd::logout "$@" | nix::cmd::run; }
nix::az::network() { nix::azure::cmd::network "$@" | nix::cmd::run; }
nix::az::network::vnet() { nix::azure::cmd::network::vnet "$@" | nix::cmd::run; }
nix::az::network::vnet::dns() { nix::azure::cmd::network::vnet::dns "$@" | nix::cmd::run; }
nix::az::network::vnet::list() { nix::azure::cmd::network::vnet::list "$@" | nix::cmd::run; }
nix::az::network::vnet::location() { nix::azure::cmd::network::vnet::location "$@" | nix::cmd::run; }
nix::az::network::vnet::show() { nix::azure::cmd::network::vnet::show "$@" | nix::cmd::run; }
nix::az::network::vnet::subnet() { nix::azure::cmd::network::vnet::subnet "$@" | nix::cmd::run; }
nix::az::network::vnet::subnet::address_prefix() { nix::azure::cmd::network::vnet::subnet::address_prefix "$@" | nix::cmd::run; }
nix::az::network::vnet::subnet::delegation() { nix::azure::cmd::network::vnet::subnet::delegation "$@" | nix::cmd::run; }
nix::az::network::vnet::subnet::list() { nix::azure::cmd::network::vnet::subnet::list "$@" | nix::cmd::run; }
nix::az::network::vnet::subnet::show() { nix::azure::cmd::network::vnet::subnet::show "$@" | nix::cmd::run; }
nix::az::query() { nix::azure::cmd::query "$@" | nix::cmd::run; }
nix::az::resource() { nix::azure::cmd::resource "$@" | nix::cmd::run; }
nix::az::resource::create() { nix::azure::cmd::resource::create "$@" | nix::cmd::run; }
nix::az::resource::delete() { nix::azure::cmd::resource::delete "$@" | nix::cmd::run; }
nix::az::resource::set() { nix::azure::cmd::resource::set "$@" | nix::cmd::run; }
nix::az::role() { nix::azure::cmd::role "$@" | nix::cmd::run; }
nix::az::role::assignment() { nix::azure::cmd::role::assignment "$@" | nix::cmd::run; }
nix::az::role::assignment::create() { nix::azure::cmd::role::assignment::create "$@" | nix::cmd::run; }
nix::az::signed_in_user::id() { nix::azure::cmd::signed_in_user::id "$@" | nix::cmd::run; }
nix::az::signed_in_user::show() { nix::azure::cmd::signed_in_user::show "$@" | nix::cmd::run; }
nix::az::signed_in_user::upn() { nix::azure::cmd::signed_in_user::upn "$@" | nix::cmd::run; }
