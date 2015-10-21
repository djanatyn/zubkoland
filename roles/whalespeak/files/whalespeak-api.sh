#!/bin/zsh

source /etc/profile.d/rvm.sh

cd /opt/whalespeak-api/web
/usr/local/rvm/gems/ruby-head/bin/rackup -o 0.0.0.0 -p 1234
