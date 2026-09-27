# SOPS

## Tools

`sops` and `age` (Brewfile). sops encrypts values in place in yaml/json/env
files; age is the key backend -- simpler than PGP, one keypair per host.

## Age key

Generate once per host (never generated or committed by this repo -- it's a
private key). `install.sh` creates the `~/.config/sops/age` directory and, if
no key is there yet, prints the exact command to paste:

```sh
age-keygen -o ~/.config/sops/age/keys.txt
```

`SOPS_AGE_KEY_FILE` (`zsh/config/20-sops.zsh`) points sops at that path;
without it sops falls back to `~/Library/Application Support/sops/age/keys.txt`
on macOS.

## Per-project config

`templates/.sops.yaml` is a skeleton, like `templates/AGENTS.md`: copy it into
a project root and fill in the age public key.

```sh
cp ~/dotfiles/templates/.sops.yaml ./.sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt   # prints the public key to paste in
```

## Editor

[`atmask/sops.nvim`](https://github.com/atmask/sops.nvim)
(`nvim/lua/plugins/sops.lua`) decrypts a sops-encrypted `.yaml`/`.yml`/`.json`
file on open and re-encrypts it on `:w`, so `nvim secret.yaml` just works --
no `sops edit` wrapper needed. It loads on `BufReadPre` rather than filetype
detection: the plugin's own decrypt hook is `BufReadPost`, which fires before
lazy.nvim's `ft` loader would attach it.
