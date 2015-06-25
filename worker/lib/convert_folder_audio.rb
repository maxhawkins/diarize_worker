#!/usr/bin/env ruby

require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: convert_folder_audio.rb IN_FOLDER IN_EXT OUT_FOLDER OUT_EXT"
end
opt_parser.parse!

if ARGV.size == 4
  in_folder, in_ext, out_folder, out_ext = ARGV

  failure = false

  Dir["#{in_folder}/*.#{in_ext}"].map do |in_file|
    basename = File.basename(in_file, ".#{in_ext}")
    out_file = File.join(out_folder, "#{basename}.#{out_ext}")

    command = "sox #{in_file} #{out_file}"
    warn command
    `#{command}`

    failure ||= $?.to_i != 0
  end

  exit 1 if failure

else
  abort opt_parser.to_s
end