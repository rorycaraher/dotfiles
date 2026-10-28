# tf() runs OpenTofu by default; set TF_BINARY=terraform in zsh-private/ where
# Terraform is needed. `command` avoids recursion and respects a mise/tfenv shim.
tf() { command "${TF_BINARY:-tofu}" "$@"; }

# aliases run through tf() so TF_BINARY applies. No tfd -- type `tf destroy`.
alias tfi='tf init'
alias tfp='tf plan'
alias tfa='tf apply'
alias tff='tf fmt'
alias tfv='tf validate'
alias tfo='tf output'
alias tfs='tf state'
alias tfw='tf workspace'
alias tfc='tf console'

# shared plugin cache + CLI config for both binaries (see terraform/config.tfrc)
export TF_CLI_CONFIG_FILE="$HOME/.config/terraform/config.tfrc"
export TOFU_CLI_CONFIG_FILE="$TF_CLI_CONFIG_FILE"

# shared tflint ruleset-plugin cache
export TFLINT_PLUGIN_DIR="$HOME/.tflint.d/plugins"

# both binaries self-complete via bash `complete -C`; bashcompinit bridges it
autoload -Uz bashcompinit && bashcompinit
for _tfbin in terraform tofu; do
  command -v "$_tfbin" >/dev/null && complete -o nospace -C "$(command -v "$_tfbin")" "$_tfbin"
done
unset _tfbin

# zsh-private/ sets TF_BINARY after this file loads, so resolve it at Tab time
_tf() {
  local bin line
  bin=$(command -v "${TF_BINARY:-tofu}") || return
  line="${(j: :)words[1,CURRENT]}"
  compadd -S '' -- ${(f)"$(COMP_LINE=$line COMP_POINT=${#line} $bin)"}
}
compdef _tf tf
