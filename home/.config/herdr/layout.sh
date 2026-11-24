#!/bin/sh
# Turn the focused herdr pane into an agent workspace:
# the agents stack top to bottom on the left, yazi (file explorer) sits on the right.
#
#   layout.sh codex           -> codex | yazi
#   layout.sh claude codex    -> claude (top) / codex (bottom) | yazi
#
# Bound to keys in config.toml ([[keys.command]], type = "shell").
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
main="${HERDR_ACTIVE_PANE_ID:?run this from a herdr keybinding}"

# split <pane> <right|down> <ratio kept by <pane>> -> prints the new pane id
split() {
  "$herdr" pane split "$1" --direction "$2" --ratio "$3" --no-focus |
    jq -er '.result.pane.pane_id'
}

files=$(split "$main" right 0.7)
"$herdr" pane run "$files" yazi

if [ $# -ge 2 ]; then
  bottom=$(split "$main" down 0.5)
  "$herdr" pane run "$bottom" "$2"
fi

"$herdr" pane run "$main" "$1"
