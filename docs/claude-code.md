# Claude and agents

## Global instructions

`claude/AGENTS.md` is symlinked to `~/.claude/AGENTS.md`; `claude/CLAUDE.md`
is a one-line `@AGENTS.md` shim so Claude Code reads it. It holds two rules:

- **Git**: agents run read-only commands (`status`, `diff`, `log`, `show`,
  `blame`) only. I run everything state-changing.
- **Terraform / OpenTofu**: agents run `fmt`, `validate`, `tflint` only. No
  `init`, `plan`, `apply`, `destroy`, `import`, mutating `state`, `taint`, or
  `workspace`. A human reads every plan.

Code style and build commands belong in each repo's own `AGENTS.md`.
`templates/AGENTS.md` is a skeleton to copy into other repos, with a
`CLAUDE.md` containing `@AGENTS.md`.

## settings.json

`~/.claude/settings.json` is merged, not linked, because Claude Code writes to
it. `install.sh` deep-merges the repo's `claude/settings.json` over the live
file: repo wins on shared keys, host-only keys (e.g. `autoMode`) are kept, one
rolling `settings.json.bak` is written, and only on drift.

Change managed settings in `claude/settings.json` and re-run `./install.sh`.
A `/config` change to a managed key is reverted on the next install.

Currently managed: `permissions.defaultMode: auto`, a `Stop` hook that renders
the `dumb` skill's context gauge if installed, the `frontend-design` plugin,
`theme: dark`.

## MCP

No global MCP servers: they cost context every session. Add at project scope.
