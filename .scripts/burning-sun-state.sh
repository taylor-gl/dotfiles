#!/usr/bin/env bash
#
# The current Burning Sun variant, as one fact on disk.
#
# The clock (cron), the bar button and any manual run all read and write this,
# so nothing has to infer the theme from the state of some other config file.
# Sourced by the switch scripts, the toggle and the i3blocks block.

BS_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/burning-sun/variant"

bs_set_variant() {
    mkdir -p "$(dirname "$BS_STATE_FILE")"
    printf '%s\n' "$1" > "$BS_STATE_FILE"
}

# Falls back to reading helix's config, which the switch scripts also rewrite,
# so a missing or hand-deleted state file still resolves to the truth rather
# than to a guess.
bs_current_variant() {
    if [[ -r "$BS_STATE_FILE" ]]; then
        local v
        v="$(<"$BS_STATE_FILE")"
        v="${v//[[:space:]]/}"
        if [[ "$v" == dark || "$v" == paper ]]; then
            printf '%s\n' "$v"
            return
        fi
    fi
    if grep -q 'burning-sun-paper' "$HOME/.config/helix/config.toml" 2>/dev/null; then
        printf 'paper\n'
    else
        printf 'dark\n'
    fi
}

# i3blocks refreshes the theme block on SIGRTMIN+BS_BLOCK_SIGNAL.
BS_BLOCK_SIGNAL=10
