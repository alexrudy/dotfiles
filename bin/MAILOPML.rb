#!/usr/bin/ruby

# Welcome to the MailAppToOPML Script
# What it does: Simply converts the RSS/Atom Newsfeeds that you have subscribed to using Mail.app
#                 and then turns it into OPML, so that it can be used in other news readers
# @author: Daniel Lewis
# Personal Email of Author: danieljohnlewis [-a-t-] gmail [-d-o-t-] com
# Authors Blog: http://vanirsystems.com/danielsblog
# This software works with Mail.app on Mac OS X. It is built using the Ruby Programming Language.
# It is licensed under LGPL.

require 'uri'
require 'find'
require 'date'

def opmlline(infoplist, topic)
        output = ""
        infopliststr = infoplist.read
         infopliststr.scan(URI.regexp) do |*matches|
                if $& != "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
                                output += "<outline text=\"#{topic}\">"
                        output += "<outline title=\"#{$&}\" text=\"#{$&}\" type=\"rss\" xmlUrl=\"#{$&}\" />"
                                output +=  "</outline>\n\n"
                end
         end
        return output
end

def writeopml(opmllines)
         f = File.new("rssfeeds.opml",  "a")
         f.puts "<?xml version=\"1.0\" encoding=\"utf-8\" ?><opml version=\"1.1\"> <head>   <title>RSS Feeds</title>   <dateCreated>#{Date.new.to_s}</dateCreated></head><body>" + opmllines + "</body></opml>"
         opmlfilepath =  Dir.pwd + "/" + f.path
         f.close
         return opmlfilepath
end

namere = /RSS\/(.*?)\//
path = File.expand_path("~/Library/Mail/RSS/")
opmllines = ""
Find.find(path) { |p1| 
        if (p1.include? "Info.plist")
                st = namere.match(p1).to_s
                topic = st.to_s[4..(st.length-2)]
                p1file = File.new(p1.to_s, "r")
                opmllines += opmlline(p1file, topic)
                p1file.close
        end
}

opmlfilepath = writeopml(opmllines)
puts "The location of your OPML file is: #{opmlfilepath}"
