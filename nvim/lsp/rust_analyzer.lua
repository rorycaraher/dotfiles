return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  -- Cargo.lock first: it sits at the workspace root, so member crates share one server
  root_markers = { "Cargo.lock", "Cargo.toml", "rust-project.json", ".git" },
}
