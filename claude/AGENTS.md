# Global agent instructions

Kept deliberately short. Code style, build/test commands, and project
conventions belong in each repo's own `AGENTS.md`, not here.

## Git

I run all state-changing git commands myself, by hand — `add`, `commit`,
`push`, `pull`, `merge`, `rebase`, `reset`, `checkout` (branch switching or
file restore), `stash`, and branch/tag create or delete.

Read-only git is fine and encouraged: `status`, `diff`, `log`, `show`,
`blame`.

This holds even if:
- I say "save my changes" or "commit this" in vague terms — ask me to
  confirm exactly what I want first.
- A task seems to need a commit to be "done" — finish the code changes and
  stop, then tell me it's ready.
- You're working autonomously through a multi-step task.

## Terraform / OpenTofu

Allowed: `fmt`, `validate`, and `tflint`.

Never run: `init`, `plan`, `apply`, `destroy`, `import`, mutating `state`
subcommands, `taint`, or `workspace` changes — for `terraform`, `tofu`, or
the `tf` wrapper. I run every plan and apply myself, by hand.

This holds even if a task seems to need `init` to proceed (stop at the code
change and tell me), and during autonomous work.

Why: plan output must be read by a human before anything touches real
infrastructure. A plan hidden inside a subagent, followed by an apply, will
eventually destroy production.
