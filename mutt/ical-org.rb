#!/usr/bin/env ruby

require "rubygems"
require "icalendar"

cals = Icalendar.parse($<)
cals.each do |cal|
  cal.events.each do |event|
    puts event.organizer
  end
end
