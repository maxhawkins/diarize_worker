#!/usr/bin/env ruby

class SegmentSplitter

  def self.split(filename, segments, options={})
    splitter = SegmentSplitter.new(options)
    splitter.split(filename, segments)
  end

  def initialize(options)
    @options = options
  end

  def split(filename, segments)
    out_dir = make_out_dir
    trim_all(filename, out_dir, segments)
  end

  private

  def make_out_dir
    out_dir = @options[:out_dir] || "segments"
    `mkdir -p #{out_dir}`
    out_dir
  end

  def trim_all(input, out_dir, segments)
    segments.each_with_index.map do |segment, i|
      output = sprintf "%s/%04d.%s", out_dir, i, @options[:format] || "flac"
      trim_audio(input, output, segment)
    end
  end

  def trim_audio(input, output, segment)
    trim_args = sprintf "00:00:%07.4f =00:00:%07.4f", segment['start_sec'], segment['end_sec']
    split_command = "sox #{input} #{output} trim #{trim_args}"
    warn split_command
    system split_command or raise "problem splitting segment #{output}"
    output
  end
end

if __FILE__ == $0

  require 'optparse'
  require 'json'

  options = {}
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: split.rb AUDIO SEG_JSON [options]"

    opts.on("--outdir [DIR]", String, "directory where split files will be placed") { |v| options[:out_dir] = v }
    opts.on("--format [EXT]", String, "file extension for the split audio files") { |v| options[:format] = v }
    opts.on("--verbose") { |v| options[:verbose] = true }
  end
  opt_parser.parse!

  if (audiofile = ARGV[0]) && (seg_json = ARGV[1])
    segments = JSON.parse(File.read(seg_json))
    puts SegmentSplitter.split(audiofile, segments, options)
  else
    abort opt_parser.to_s
  end

end