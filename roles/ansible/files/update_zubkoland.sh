#!/bin/zsh

cd /var/local/zubkoland; git pull
ansible-playbook -i hosts site.yml -s -K
