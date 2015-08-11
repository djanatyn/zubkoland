#!/usr/bin/env ruby

require 'net/http'

# url of redmine server
tracker_url = "http://tracker.zubkoland.org/"

# default to 
STATE="CRITICAL"

# HTTP status check
begin
  response = Net::HTTP.get_response(URI(tracker_url))

  if (response.is_a?(Net::HTTPSuccess))
    puts "OK: #{response}"
  elsif not (response.value.nil?)
    puts "CRITICAL: #{response.value}"
  else
    puts "UNKNOWN: #{response}"
  end

rescue EOFError => e
  puts "CRITICAL: #{e}"
  exit
end

