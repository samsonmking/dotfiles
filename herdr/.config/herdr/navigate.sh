#!/bin/sh

case "${1:-}" in
    left)  key=ctrl+h ;;
    down)  key=ctrl+j ;;
    up)    key=ctrl+k ;;
    right) key=ctrl+l ;;
    *) exit 2 ;;
esac

herdr=${HERDR_BIN_PATH:-herdr}
pane=${HERDR_ACTIVE_PANE_ID:?missing active Herdr pane}
processes=$("$herdr" pane process-info --pane "$pane") || exit 1
forward=$(printf '%s\n' "$processes" | jq -r '
    any(.result.process_info.foreground_processes[];
        .name | test("^[.]?(nvim(diff)?|fzf)(-wrapped)?$"; "i"))
') || exit 1

# Neovim handles the key locally and calls pane focus directly at a split edge.
if [ "$forward" = true ]; then
    exec "$herdr" pane send-keys "$pane" "$key"
fi
exec "$herdr" pane focus --pane "$pane" --direction "$1"
