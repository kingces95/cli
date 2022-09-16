source "${NIX_DIR_NIX_USR}/alias.sh"


alias r="nix::shell::pushd ${NIX_REPO_DIR}"
alias rel="nix::loader::reload"
alias reg="nix::loader::regenerate"

alias pd-nix="nix::shell::pushd ${NIX_DIR}"
alias pd-nix-src="nix::shell::pushd ${NIX_DIR}/src"
alias pd-usr="nix::shell::pushd ${NIX_DIR}/usr"
alias pd-tst="nix::shell::pushd ${NIX_DIR}/tst"
alias pd-aadj="nix::shell::pushd ${NIX_DIR}/tst/src/aadj"
alias pd-kusto="nix::shell::pushd ${NIX_REPO_DIR_KUSTO}"
alias pd-http="nix::shell::pushd ${NIX_REPO_DIR}/http"
alias pd-dp="nix::shell::pushd ${NIX_REPO_DIR}/http/dataplane"

alias pd-swag-rm="nix::shell::pushd ${NIX_REPO_DIR_SRC}/sdk/specification/devtestcenter/resource-manager/Microsoft.Devcenter/preview"

# projects/aadj-project-df/users/me/virtualmachines/aadj-vm0-df
alias aadj-curl="nix::dataplane::vm::put aadj-project-df aadj-pool aadj-vm0-df"

alias who="fd-who"
alias dp="nix::bash::dump::declarations"

alias ppe3="fd-switch-to-ppe3"

alias su-admin="fd-login-as-administrator"
alias su-net="fd-login-as-network-administrator"
alias su-me="fd-login-as-me"
alias su-dev="fd-login-as-developer"
alias su-usr="fd-login-as-vm-user"

alias me="fd-my-profile"
alias nix="fd-nix | grep -i"
alias var="fd-nix-env | grep -i"
alias cpc="fd-nix-cpc | grep -i"
alias fid="fd-nix-fid | grep -i"
alias www="fd-nix-env-www"
alias ctx="nix::context::print | a3f"

alias pd="nix::shell::pushd"
alias u="pd .."
alias uu="u && u"
alias uuu="uu && u"
alias uuuu="uuu && u"

alias p="nix::shell::popd"
alias pp="p && p"
alias ppp="pp && p"
alias pppp="ppp && p"

alias ag="alias -p | grep "
alias callees="nix::function::callee::tree"
alias callers="nix::function::caller::tree"

alias cmd="nix::cmd::compile"
alias cmd-exe="nix::cmd::run"
alias x="nix::cmd::run"
alias cmd-show="nix::cmd::compile | nix::line::join"
alias cmd-emit="nix::cmd::compile | nix::cmd::pretty"

alias fit="fd-line-fit"
alias exe="fd-line-exe"
alias skip="fd-line-skip"
alias except="nfd-line-except"