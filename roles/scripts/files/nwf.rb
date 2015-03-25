#!/usr/bin/env ruby

require 'trollop'
require 'typhoeus'
require 'json'

def running? pid
  begin
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end
end

opts = Trollop::options do
  opt :poll_time , %Q{time between polls in seconds}, :short => 'p', :default => 5
  opt :exact, %Q{find exact match},:default => false
  opt :command, %Q{command to run when process finishes}, :type => String, :default => ''
  opt :no_push, %Q{do not push when command finishes}
end

File.umask(0002)

api_key_file="#{ENV['HOME']}/.pb_key"

if ! File.exist?(api_key_file)
  puts "Please put your api key as the sole contents of #{api_key_file}."
  exit 1
end

api_key=File.open(api_key_file,'r').read.chomp

abort "give one PID, or one process to search for as an argument!" if ARGV.length != 1
process = ARGV.shift

# find matching processes
# -----------------------
@processes = []

# if it's in /proc/ just use that PID
if File.exist?("/proc/#{process}")
  pid = process
  cmdline = %x{ps -p #{pid} -o cmd | awk 'NR==2 {print; exit}'}.chomp

  @processes.push({pid: pid.to_i, cmdline: cmdline})
else
  pgrep_output = %x{pgrep -f -a #{'-x' if opts[:exact]} '#{process}'}.chomp
  abort "no processes found!" if pgrep_output.empty?

  # grab all the processes with pgrep
  pgrep_output.split("\n").each do |line|
    pid, cmdline = line.scan(%r{^(\d+) (.+)$}).flatten

    @processes.push({pid: pid.to_i, cmdline: cmdline})
  end
end

# remove the current process from the list
current_pid = Process.pid
@processes.reject! {|p| p[:pid] == current_pid }

# die if you don't find anything
abort "no processes found!" if @processes.empty?

if @processes.length == 1
  puts "found exactly one process, continuing."
else
  # too many processes
  puts "found too many processes; narrow your query, use --exact, or just pass a PID:"

  # print out each one all nice and pretty
  @processes[0..10].each {|p| puts "- #{p[:cmdline]} (#{p[:pid]})" }
  puts "..." if @processes.length > 10; abort
end

# we've found the right process, just monitor and push when done
process = @processes.first
puts "monitoring: #{process[:cmdline]} (#{process[:pid]})"

# sleep while the process is running
while running? process[:pid]
  sleep opts[:poll_time]
end

puts "process gone, stopping."

# send a push request
unless opts[:no_push]
  body = JSON.dump({'type' => 'note', 'title' => 'notify-when-finished', 'body' => "#{process[:cmdline]} finished!"})

  response = Typhoeus.post('https://api.pushbullet.com/v2/pushes',
               headers: {'Content-Type' => 'application/json'},
               body: body,
               userpwd: api_key)

  puts "unsuccessful push!" if ! response.success?
  puts "successful push!" if response.success?
end

# run the command if we have one
unless opts[:command].empty?
  puts "running command: #{opts[:command]}"
  puts %x{#{opts[:command]}}
end
