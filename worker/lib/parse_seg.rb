#!/usr/bin/env ruby

class SegfileParser
  class << self

    def parse(segfile)
      segfile.split("\n").
        grep(/^[^;]/).
        map(&:split).
        map do |_,_,start,length,gender,_,_,cluster|
          start_sec = start.to_f / 100
          end_sec = length.to_f / 100 + start_sec
          {start_sec:start_sec, end_sec:end_sec, gender:gender, cluster:cluster}
        end.
        sort_by do |seg|
          seg[:start_sec]
        end
    end

  end
end

if __FILE__ == $0

  require 'optparse'
  require 'json'

  options = {}
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: parse_seg.rb SEGFILE [options]"
  end
  opt_parser.parse!

  if file = ARGV[0] || !STDIN.tty?
    segfile = STDIN.tty? ? File.read(file) : STDIN.read
    segments = SegfileParser.parse(segfile)
    puts segments.to_json
  else
    abort opt_parser.to_s
  end

end