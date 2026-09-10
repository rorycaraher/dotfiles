<!--
Project AGENTS.md skeleton. Copy to a repo root, fill in, delete this comment
and any sections that don't apply.

  cp ~/dotfiles/templates/AGENTS.md ./AGENTS.md
  printf '@AGENTS.md\n' > ./CLAUDE.md   # one-line shim so Claude Code reads it

Keep this file self-contained: no @imports (Codex / Cursor / Zed read them as
literal text). Short and specific beats long and vague.
-->

# <project> — agent instructions

One or two sentences: what this repo is, what it deploys/produces.

## Setup

Commands to get from clean clone to working state (install, generate, etc.).

## Build / test / lint

- Build: `...`
- Test (all): `...`
- Test (single): `...`
- Lint / format: `...`

Run the relevant check after changes and before handing back.

## Conventions

- Language / framework versions (pin source: `mise.toml`, `.terraform-version`, …)
- Structure: where things live, how modules/packages are organised
- Naming, error handling, logging patterns specific to this repo
- Commit / PR expectations

## Do not touch

- Generated files (list globs)
- Paths / resources that require human review (infra, migrations, secrets)
- Anything the CI or a human must run by hand

## Gotchas

- Non-obvious traps: flaky commands, required env/auth, ordering constraints
