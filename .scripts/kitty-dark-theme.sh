#!/usr/bin/env bash
#
# Superseded by switch-to-{dark,light}-theme.sh, which now copy the generated
# Burning Sun palette into kitty/current-theme.conf directly. Kept as a thin
# shim so anything still calling this by name keeps working.
set -euo pipefail
exec "$HOME/.scripts/switch-to-dark-theme.sh"
