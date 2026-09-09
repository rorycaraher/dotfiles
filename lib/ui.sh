# Minimal ANSI output helpers, sourced by the scripts. No dependencies.
#
# Colour is turned off automatically when stdout is not a terminal, when TERM
# is "dumb", or when NO_COLOR is set (https://no-color.org) -- so piped or
# redirected output stays clean.

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ]; then
  C_RESET=$'\033[0m'  ; C_BOLD=$'\033[1m'   ; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'   ; C_GREEN=$'\033[32m' ; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'  ; C_CYAN=$'\033[36m'
else
  C_RESET= ; C_BOLD= ; C_DIM= ; C_RED= ; C_GREEN= ; C_YELLOW= ; C_BLUE= ; C_CYAN=
fi

# Bold section header:  ==> message
step() { printf '%s==>%s %s\n' "$C_BOLD$C_BLUE" "$C_RESET" "$*"; }

# Coloured 7-wide status tag followed by detail:  tag <colour> LABEL detail...
tag() {
  local colour="$1" label="$2"; shift 2
  printf '%s%-7s%s %s\n' "$colour" "$label" "$C_RESET" "$*"
}

# Dimmed dry-run line:  [dry-run] message
dry() { printf '%s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"; }

# Warning (yellow) and error (red), both to stderr.
warn() { printf '%s%s%s\n' "$C_YELLOW" "$*" "$C_RESET" >&2; }
err()  { printf '%s%s%s\n' "$C_RED"    "$*" "$C_RESET" >&2; }
