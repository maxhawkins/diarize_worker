#!/usr/bin/env ruby

require 'tmpdir'

class Diarizer

  LIUM_JAR_PATH = File.expand_path("LIUM_SpkDiarization.jar", File.dirname(__FILE__))

  def self.diarize(audiofile, options)
    diarizer = Diarizer.new(options)
    diarizer.diarize(audiofile)
  end

  def initialize(options)
    @options = options
  end

  def diarize(audiofile)
    input = File.expand_path(audiofile)
    Dir.mktmpdir('diarizer') do |tmpdir|
      output = File.join(tmpdir, "output.seg")
      run_lium(input, output)
      File.read(output)
    end
  end

  def run_lium(input, output)
    command = lium_command(input,output)
    warn command
    `#{command}`
    raise "problem with diarization" unless $?.to_i == 0
  end

  def lium_command(input, output)
    cmd = []
    cmd << "java"
    cmd << "-Xmx1G"
    cmd << "-jar"
    cmd << LIUM_JAR_PATH
    cmd << "--fInputMask=#{input}"
    cmd << "--sOutputMask=#{output}"
    cmd << "--doCEClustering" unless @options[:skip_clustering]
    cmd << "audio"
    cmd.join(' ')
  end

end

if __FILE__ == $0

  require 'optparse'
  require 'json'

  options = {}
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: diarize.rb AUDIO [options]"

    opts.on("--skip-clustering", "makes diarization faster but less accurate") { |v| options[:skip_clustering] = true }
  end
  opt_parser.parse!

  if audiofile = ARGV[0]
    puts Diarizer.diarize(audiofile, options)
  else
    abort opt_parser.to_s
  end

end