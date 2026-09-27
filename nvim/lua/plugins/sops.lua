-- transparent decrypt-on-open / re-encrypt-on-save for sops files; sops
-- itself must be on PATH (Brewfile) and SOPS_AGE_KEY_FILE set (zsh/config/20-sops.zsh)
--
-- must load on BufReadPre, not ft: the plugin hooks BufReadPost to decrypt,
-- and ft-based lazy loading only fires once BufReadPost is already running,
-- too late to register that autocmd for the buffer being opened.
--
-- sops resolves .sops.yaml by walking up from the process's cwd, not from
-- the file being written -- the plugin's --filename-override only supplies
-- the string matched against path_regex once a config is found, it doesn't
-- change where sops looks for one. So if nvim's cwd isn't inside the
-- project on :w, encryption fails with "no matching creation rules found"
-- even though decrypt (which reads keys from the file's own embedded
-- metadata, no config needed) works regardless of cwd. Chdir to the file's
-- own directory for the encrypt call and restore right after.
return {
  "atmask/sops.nvim",
  event = { "BufReadPre *.yaml", "BufReadPre *.yml", "BufReadPre *.json" },
  config = function(_, opts)
    local group = vim.api.nvim_create_augroup("SopsChdir", { clear = true })
    local patterns = { "*.yaml", "*.yml", "*.json" }

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      pattern = patterns,
      callback = function(a)
        vim.b[a.buf].sops_prev_cwd = vim.fn.getcwd()
        vim.fn.chdir(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(a.buf), ":h"))
      end,
    })

    require("sops").setup(opts)

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      pattern = patterns,
      callback = function(a)
        local prev = vim.b[a.buf].sops_prev_cwd
        if prev then vim.fn.chdir(prev) end
      end,
    })
  end,
}
