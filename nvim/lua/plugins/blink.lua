return {
  "saghen/blink.cmp",
  -- release tags ship a prebuilt fuzzy matcher; no Rust toolchain needed
  version = "1.*",
  -- not lazy: blink registers its LSP capabilities (snippets, for emmet)
  -- on load, which must happen before the first server starts
  lazy = false,
  opts = {
    keymap = { preset = "default" },
    completion = { documentation = { auto_show = true } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
