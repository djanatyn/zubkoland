#!/bin/zsh

cd /var/local/zubkoland; sudo git pull
ansible-playbook -i hosts site.yml -s -K
