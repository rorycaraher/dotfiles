# 20-terraform.zsh

# OpenTofu is the default. Where Terraform is still needed -- a codebase not
# yet migrated, or a provider/backend OpenTofu doesn't support -- set
#   export TF_BINARY=terraform
# in ~/.config/zsh-private/*.zsh and every tf* command below follows. `command`
# keeps the wrapper from recursing and lets a version manager's shim (mise,
# tfenv, ...) resolve the binary transparently.
tf() { command "${TF_BINARY:-tofu}" "$@"; }

# oh-my-zsh-aligned aliases, all routed through the wrapper so they respect
# $TF_BINARY. No `tfd` on purpose -- type `tf destroy` in full.
alias tfi='tf init'
alias tfp='tf plan'
alias tfa='tf apply'
alias tff='tf fmt'
alias tfv='tf validate'
alias tfo='tf output'
alias tfs='tf state'
alias tfw='tf workspace'
alias tfc='tf console'

# Shared plugin cache + CLI config for both binaries (see terraform/config.tfrc).
export TF_CLI_CONFIG_FILE="$HOME/.config/terraform/config.tfrc"
export TOFU_CLI_CONFIG_FILE="$TF_CLI_CONFIG_FILE"

# Shared tflint plugin cache -- same idea as the provider cache, for tflint's
# ruleset plugins.
export TFLINT_PLUGIN_DIR="$HOME/.tflint.d/plugins"

# Both binaries self-complete via the bash `complete -C` protocol; bashcompinit
# bridges that into zsh. compinit already ran in 10-completion.zsh.
autoload -Uz bashcompinit && bashcompinit
for _tfbin in terraform tofu; do
  command -v "$_tfbin" >/dev/null && complete -o nospace -C "$(command -v "$_tfbin")" "$_tfbin"
done
# Point `tf`'s completion at whichever binary it resolves to.
command -v "${TF_BINARY:-tofu}" >/dev/null &&
  complete -o nospace -C "$(command -v "${TF_BINARY:-tofu}")" tf
unset _tfbin
