# agent-msg: send a message from this coding agent to another agent running
# in herdr (claude, codex, ...). The message is submitted as a prompt in the
# target's pane, tagged with the sender's pane id so the target can reply.
#
#   agent-msg <target> <message...>
#   agent-msg list
#
# <target> is a pane id (w7:p3), a herdr agent name, or an agent kind
# (claude, codex). A kind resolves to the single agent of that kind in the
# caller's tab, then the caller's workspace; if that is ambiguous, pass a
# pane id from `agent-msg list`.
#
# Installed via writeShellApplication in home.nix (adds jq, strict mode).

herdr="${HERDR_BIN_PATH:-herdr}"

die() { printf 'agent-msg: %s\n' "$*" >&2; exit 1; }
usage() { die "usage: agent-msg <pane-id|name|claude|codex> <message...>  |  agent-msg list"; }

[ -n "${HERDR_PANE_ID:-}" ] || die "not inside a herdr pane (HERDR_PANE_ID unset); messaging only works between agents running in herdr"

agents=$("$herdr" agent list) || die "could not list herdr agents"

if [ "${1:-}" = list ]; then
  jq -r --arg me "$HERDR_PANE_ID" '
    .result.agents[]
    | [ .pane_id, .agent, (.name // "-"), .agent_status, .cwd,
        (if .pane_id == $me then "(you)" else "" end) ]
    | @tsv' <<<"$agents"
  exit 0
fi

[ $# -ge 2 ] || usage
target=$1; shift
text=$*
[ -n "$text" ] || usage

me_kind=$(jq -r --arg me "$HERDR_PANE_ID" \
  '.result.agents[] | select(.pane_id == $me) | .agent' <<<"$agents")
[ -n "$me_kind" ] || me_kind=agent

# Resolve the target to exactly one pane id (never ourselves).
pane=$(jq -r --arg t "$target" --arg me "$HERDR_PANE_ID" \
  --arg tab "${HERDR_TAB_ID:-}" --arg ws "${HERDR_WORKSPACE_ID:-}" '
  [ .result.agents[] | select(.pane_id != $me) ] as $a
  | ( [ $a[] | select(.pane_id == $t or .name == $t) ] ) as $exact
  | if ($exact | length) > 0 then $exact
    else
      [ $a[] | select(.agent == $t) ] as $kind
      | ([ $kind[] | select(.tab_id == $tab) ]) as $in_tab
      | ([ $kind[] | select(.workspace_id == $ws) ]) as $in_ws
      | if ($in_tab | length) > 0 then $in_tab
        elif ($in_ws | length) > 0 then $in_ws
        else $kind end
    end
  | if length == 1 then .[0].pane_id
    elif length == 0 then "none"
    else "ambiguous" end' <<<"$agents")

case "$pane" in
  none) die "no agent matches '$target' (run: agent-msg list)" ;;
  ambiguous) die "'$target' matches several agents; pass a pane id (run: agent-msg list)" ;;
esac

msg="[agent-msg from $me_kind in pane $HERDR_PANE_ID]
$text

(To reply, run: agent-msg $HERDR_PANE_ID \"<your reply>\")"

if ! out=$("$herdr" agent prompt "$pane" "$msg" 2>&1); then
  case "$out" in
    *agent_blocked*) die "agent in $pane is waiting on an approval or question; the user has to answer it first" ;;
    *) die "delivery to $pane failed: $out" ;;
  esac
fi
printf 'agent-msg: delivered to %s\n' "$pane"
