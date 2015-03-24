#!/bin/zsh

cd /var/local/zubkoland; git up
ansible-playbook -i hosts site.yml -s -K
