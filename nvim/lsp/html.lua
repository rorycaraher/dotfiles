return {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
  init_options = {
    provideFormatter = true,
    -- css inside <style> and style="" gets completion, hover and colour swatches
    embeddedLanguages = { css = true },
    configurationSection = { "html", "css" },
  },
}
