#!/usr/bin/env bash
#
# Flip the desktop between the two Burning Sun variants. Bound to the theme
# block in the i3 bar; also fine to run by hand.

set -euo pipefail
source "$HOME/.scripts/burning-sun-state.sh"

if [[ "$(bs_current_variant)" == dark ]]; then
    exec "$HOME/.scripts/switch-to-light-theme.sh"
else
    exec "$HOME/.scripts/switch-to-dark-theme.sh"
fi
