#!/usr/bin/env bash
# agents — DEPRECATED wrapper for skillforge
#
# This command has been renamed to 'skillforge'.
# This wrapper will be removed in a future version.
#
# Update any scripts or aliases that call 'agents' to use 'skillforge' instead.

printf '[DEPRECATED] The "agents" command has been renamed to "skillforge".\n' >&2
printf '             Update your scripts and aliases. This wrapper will be removed in a future version.\n\n' >&2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/skillforge.sh" "$@"
