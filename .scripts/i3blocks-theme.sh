#!/usr/bin/env bash
#
# i3blocks: current Burning Sun variant, click to flip.
#
# Colours are read back out of ~/.Xresources rather than hardcoded, so the
# button restyles itself along with everything else when the variant changes.

set -uo pipefail
source "$HOME/.scripts/burning-sun-state.sh"

# Any mouse button toggles. Detached with setsid because the switch script
# runs `i3-msg reload`, which restarts i3blocks and would otherwise kill this
# process mid-flight. The switch script signals the bar when it is done.
if [[ -n "${BLOCK_BUTTON:-}" && "${BLOCK_BUTTON}" != 0 ]]; then
    setsid "$HOME/.scripts/toggle-theme.sh" >/dev/null 2>&1 </dev/null &
fi

xres() {
    local v
    v="$(xrdb -query 2>/dev/null | awk -v k="$1" '$1 == k":" {print $2; exit}')"
    printf '%s\n' "${v:-$2}"
}

ember="$(xres '*i3wm.ember' '#ff4a00')"

case "$(bs_current_variant)" in
    paper) glyph="☀" ;;   # the full sun
    *)     glyph="○" ;;   # the eclipse ring
esac

# The glyph alone, in the rubric — the one lit thing on the bar.
printf '<span foreground="%s">%s</span> \n' "$ember" "$glyph"
