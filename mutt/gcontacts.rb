#!/usr/bin/env ruby1.8
##
# File: contactos.rb
# Author: Horacio Sanson (hsanson at gmail)
# Date: 2010/01/22
#
# Descr:
# Small script to facilitate use of GMail contacts within mutt email client.
#
# Features:
# - Generates a list of group and subscribe commands generated from your
# GMail contacts groups that can be sourced from your muttrc file.
# - Can be used to search for contacts within mutt using the query_command
# option in the same way abook or ldbd are used.
# - Results are cached for a period of time (configurable) to speed up
# queries.
#
# Installation:
# To use this script you need ruby and rubygems 1.8 and the gdata gem. To
# install these in Ubuntu/Kubuntu use the following commands.
#
# sudo aptitude install ruby1.8 rubygems-1.8 libopenssl-ruby1.8
# sudo gem1.8 install gdata
#
# Make sure to read the comments below to learn how to configure this script
# to work with your GMail account.
#
# Then in your muttrc file add these lines:
#
# source '/PATH_TO_SCRIPT/contactos.rb --groups|'
# source '/PATH_TO_SCRIPT/contactos.rb --subscribes|'
# set query_command ="/PATH_TO_SCRIPT/contactos.rb --mutt %s"
# set query_format="%4c %t %-40.40a %-40.40n %?e?(%e)?"
# bind editor <Tab> complete-query
# bind editor ^T complete
#
# with this configuration you will be able to use your GMail groups in all
# regexp's and create hooks for them. Pressing <tab> when filling a To: or
# From: header will give you a list of options to choose or auto complete the
# address if only one matches.
#
# Resources:
# - http://antonyjepson.wordpress.com/2009/06/27/using-your-gmail-contacts-in-mutt/
# - http://www.chizang.net/alex/blog/code/mutt-query-gmail/
# - http://castrojo.wordpress.com/2009/01/28/gmail-contacts-with-mutt/
# - http://wiki.mutt.org/?QueryCommand
# - http://code.google.com/apis/contacts/docs/3.0/reference.html#Feeds
# - http://code.google.com/apis/gdata/articles/gdata_on_rails.html#GettingStarted
#
# TODO:
# - Mutt only sources the group list once on startup. If we add new groups or
# add contacts to a group these won't be reflected in mutt until we restart
# it. Not really a problem because mutt has the fastest start up time.
# - Create a script to add contacts from within mutt.
# - Find if create-alias can accept a script as parameter.

require "rubygems"
require "gdata"
require "fileutils"
require "pp"

## Set up here your GMail account username and password
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"

# You may create a group in you GMail contacts and add all the mailing lists
# you are subscribed into that group. This script will generate a bunch of
# subscribe commands for all addresses in that group.
MAILISTGROUP="Mailing Lists"

# Make sure this value is larger than the total number of contacts you have.
MAXRESULTS=999

# How much time before the local cache expires in seconds.
UPDATE_INTERVAL=3600

# Where to store the local cache for faster query times.
CACHEFILE="~/.mutt/cache/gcontacts"

###############################################################################
## DON'T CHANGE ANYTHING BELOW THIS POINT
## unless you know what your are doing
###############################################################################

class Contact
    attr_accessor :emails, :groups
    attr_reader :name, :id
    def initialize(id, name="")
        @id = id
        @name = name
        @emails = []
        @groups = []
    end

    def mutt_match(pattern)
        return mutt_fmt if @name and @name =~ Regexp.new(pattern,Regexp::IGNORECASE)

        str = ""
        @emails.each { |email|
            str << "#{email}\t#{@name||email}\t#{@groups.first}\n" if email =~ Regexp.new(pattern,Regexp::IGNORECASE)
        }
        str
    end

    def mutt_fmt
        str = ""
        @emails.each { |email|
            str << "#{email}\t#{@name||email}\t#{@groups.first}\n"
        }
        str
    end
end

# This method updates the local cache if the cache file is not present or if the
# UPDATE_INTERVAL has expired.
def update_cache
    user_hash = nil
    if ! File.exists?(File.expand_path(CACHEFILE)) or Time.now - File.stat(File.expand_path(CACHEFILE)).mtime > UPDATE_INTERVAL
        #STDERR << "Updating from gmail\n"
        user_hash = {}
        client = GData::Client::Contacts.new

        begin
            client.clientlogin("#{USERNAME}@gmail.com", PASSWORD)
        rescue GData::Client::AuthorizationError
            STDERR << "Failed to authenticate\n"
            return nil
        rescue => e
            STDERR << "Failed to log into Gmail: #{e}\n"
        end

        # Create a hash list of all groups
        group_hash = {}
        groups = client.get("http://www.google.com/m8/feeds/groups/#{USERNAME}%40gmail.com/full?max-results=#{MAXRESULTS}").to_xml
        groups.elements.each('entry') { |entry|
            name = entry.elements['title'].text.gsub("System Group: ","")
            id = entry.elements['id'].text
            group_hash[id] = name
        }

        # Create a hash list of all users
        feeds = client.get("http://www.google.com/m8/feeds/contacts/#{USERNAME}%40gmail.com/full?max-results=#{MAXRESULTS}").to_xml
        feeds.elements.each('entry') { |entry|
            name = entry.elements['title'].text
            id = entry.elements['id'].text
            new_contact = Contact.new(id, name)

            entry.elements.each('gd:email') { |email|
                new_contact.emails << email.attribute('address').value
            }
            entry.elements.each('gContact:groupMembershipInfo') { |group|
                new_contact.groups << group_hash[group.attribute('href').to_s]
            }
            user_hash[id] = new_contact
        }

        File.open(File.expand_path(CACHEFILE),"wb") { |fd|
            fd << Marshal.dump(user_hash)
        }
    end
end

def load_cache
    #STDERR << "Updating from local cache\n"
    user_hash = {}
    if File.exists?(File.expand_path(CACHEFILE))
        File.open(File.expand_path(CACHEFILE),"rb") { |fd|
            user_hash = Marshal.load(fd.read)
        }
    end

    return user_hash
end

def print_help
    puts "usage: "
    puts " contactos.rb --mutt [pattern]"
    puts " contactos.rb --groups"
    puts " contactos.rb --subscribes"
    puts " contactos.rb --aliases"
end

if ARGV.empty?
    print_help
else
    update_cache
    contacts = load_cache
    case ARGV[0]
    when "--mutt"
        puts "" # Mutt ignores the first line
        if ARGV[1]
            contacts.each { |k, contact|
                STDOUT << contact.mutt_match(ARGV[1])
            }
        else
            contacts.each { |k, contact|
                STDOUT << contact.mutt_fmt
            }
        end
    when "--groups"
        contacts.each { |k,contact|
            contact.groups.each { |g|
                puts "group -group \"#{g}\" -addr #{contact.emails.join(', ')}" if ! contact.emails.empty?
            }
        }
    when "--subscribes"
        contacts.each { |k,contact|
            contact.groups.each { |g|
                if g == MAILISTGROUP and contact.emails.size > 0
                    puts "subscribe #{contact.emails.join(' ')}"
                end
            }
        }
    when "--aliases"
        contacts.each { |k,contact|
            contact.emails.each { |e|
                if contact.name
                    puts "alias \"#{contact.name}\" #{contact.name} <#{e}>"
                else
                    puts "alias \"#{e}\" #{e}"
                end
            }
        }
    when "-v"
    when "--version"
        puts "Contactos.rb version 0.2.0, Copyright 2010 Horacio Sanson"
    when "-h"
    when "--help"
        print_help
    else
        print_help
    end
end

