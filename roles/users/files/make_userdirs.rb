#!/bin/env ruby

require 'fileutils'

# this shouldn't be run by normal users
runner=%x{whoami}.chomp
abort "must be run as root!" unless runner == 'root'

abort "usage: #{$0} <user>" unless ARGV.length == 1
user = ARGV[0]

mail_directory = "/home/#{user}/Mail/"

unless File.exists? mail_directory
  %x{/usr/bin/maildirmake #{mail_directory}}
  File.chown user, user, mail_directory
end

# make regular directories here
directories = %W{public_html}
directories.map! {|d| "/home/#{user}/#{d}"}

directories.each do |dir|
  unless File.exists? dir
    FileUtils.mkdir dir, :mode => 0755
    FileUtils.chown user, user, dir
  end
end
