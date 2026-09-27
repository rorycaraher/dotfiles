-- transparent decrypt-on-open / re-encrypt-on-save for sops files; sops
-- itself must be on PATH (Brewfile) and SOPS_AGE_KEY_FILE set (zsh/config/20-sops.zsh)
--
-- must load on BufReadPre, not ft: the plugin hooks BufReadPost to decrypt,
-- and ft-based lazy loading only fires once BufReadPost is already running,
-- too late to register that autocmd for the buffer being opened.
return {
  "atmask/sops.nvim",
  event = { "BufReadPre *.yaml", "BufReadPre *.yml", "BufReadPre *.json" },
  opts = {},
}
