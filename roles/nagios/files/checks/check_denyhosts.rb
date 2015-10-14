#!/usr/bin/env ruby

status = %x{systemctl is-active denyhosts}

if status =~ /^active$/
  puts "OK: #{status}"
else
  puts "CRITICAL: #{status}"
end
