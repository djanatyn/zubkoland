#!/bin/env ruby

# this shouldn't be run by normal users
runner=%x{whoami}.chomp
abort "must be run as root!" unless runner == 'root'

abort "usage: #{$0} <user>" unless ARGV.length == 1
user = ARGV[0]

mail_directory = "/home/#{user}/Mail/"

if File.exists? mail_directory
  puts "#{mail_directory} already exists!"
  exit 0
else
  # otherwise we run maildirmake so maildrop can deliver
  %x{/usr/bin/maildirmake #{mail_directory}}
  %x{chown -R #{user} #{mail_directory}}
end
