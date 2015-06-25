#!/usr/bin/env ruby

require 'json'

puts ARGF.each_line.map{|j| JSON.parse(j) }.to_json