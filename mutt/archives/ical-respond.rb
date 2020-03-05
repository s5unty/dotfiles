#!/usr/bin/env ruby
require "rubygems"
require "icalendar"
require "optparse"

def toomany(what)
    raise OptionParser::InvalidOption.new("more than one #{what} specified")
end

mode = nil
responder = nil
message = ""
optparse = OptionParser.new do |opts|
  opts.banner = 'usage: icalrespond.rb -a|d|t -i identity [-m message]'

  opts.on('-a', '--accept', 'Accept the appointment') do
    toomany 'mode' if mode
    mode = "Accepted"
  end

  opts.on('-d', '--decline', 'Decline the appointment') do
    toomany 'mode' if mode
    mode = "Declined"
  end

  opts.on('-i', '--identity email', 'Specify which responder you are') do |email|
    toomany 'identity' if responder
    responder = email
  end

  opts.on('-m', '--message msg', 'Message to accompany response') do |msg|
    message << msg
  end

  opts.on('-t', '--tentative', 'Tentatively accept') do
    toomany 'mode' if mode
    mode = "Tentative"
  end

end

begin
  optparse.parse!
rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
  $stderr.puts e
  $stderr.puts optparse
  exit 1
end

if !mode
  $stderr.puts "icalrespond.rb: exactly one option required"
  optparse.summarize() {|l| $stderr.puts l}
  exit 2
end

if !responder
  $stderr.puts "icalrespond.rb: identity not specified"
  optparse.summarize() {|l| $stderr.puts l}
  exit 3
end

cals = Icalendar.parse($<)
resp = Icalendar::Calendar.new
resp.ip_method = "REPLY"
cals.each do |cal|
  cal.events.each do |event|
    resp.event do
      uid event.uid
      dtstart event.dtstart
      dtend event.dtend
      summary mode + ': ' + event.summary
      description message.length > 0 ? message : event.description
      klass event.klass
      properties["attendee;partstat=#{mode}"] = [ URI.parse(responder) ]
    end
  end
end
puts resp.to_ical
