# Terraform / OpenTofu

## `tf`

A shell function (`zsh/config/20-terraform.zsh`) running
`${TF_BINARY:-tofu}`. The `tf*` aliases (see [shell.md](shell.md)) go through
it, so setting `TF_BINARY` switches all of them. There is no `tfd`; type
`tf destroy`.

`tofu` comes from mise (`opentofu = "1.12"` in `mise/config.toml`, minor-pinned
so a state-format bump is a deliberate edit). `.terraform-version` and
`.opentofu-version` files are honoured.

## A host that needs Terraform

```sh
echo 'export TF_BINARY=terraform' > ~/.config/zsh-private/terraform.zsh
```

Install `terraform` however that host standardises (Homebrew, `tfenv`). If a
version manager owns it, keep it out of `mise` so there aren't two shims.

## Shared config

`terraform/config.tfrc`, pointed to by both `TF_CLI_CONFIG_FILE` and
`TOFU_CLI_CONFIG_FILE`:

- `plugin_cache_dir = ~/.terraform.d/plugin-cache`: one provider download
  across projects.
- `disable_checkpoint = true`: no upstream version checks.

`TFLINT_PLUGIN_DIR` is `~/.tflint.d/plugins`.

## Lock files

After adding or bumping a provider, lock every platform CI uses or Linux CI
rejects the lock file:

```sh
tofu providers lock -platform=linux_amd64 -platform=darwin_arm64
```

## Editor

`terraform-ls` (Brewfile) is the language server in both nvim and Zed; Zed
formats `.tf` on save.

## Agents

Agents may run `fmt`, `validate` and `tflint` only. See [claude-code.md](claude-code.md).
