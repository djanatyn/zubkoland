#!/bin/env ruby

require 'fileutils'

# this shouldn't be run by normal users
runner=%x{whoami}.chomp
abort "must be run as root!" unless runner == 'root'

abort "usage: #{$0} <user>" unless ARGV.length == 1
user = ARGV[0]

mail_directory = "/home/#{user}/Mail/"

if File.exists? mail_directory
  break
else
  # otherwise we run maildirmake so maildrop can deliver
  %x{/usr/bin/maildirmake #{mail_directory}}
  %x{chown -R #{user} #{mail_directory}}
end

# make regular directories here
directories = %W{public_html}

directories.each do |dir|
  if File.exists? "/home/#{user}/#{dir}"
    break
  else
    File.mkdir dir, :mode => 0755
    FileUtils.chown user, user, dir
  end
end
