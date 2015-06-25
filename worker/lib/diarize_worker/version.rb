#!/usr/bin/env ruby

module DiarizeWorker
  VERSION = "0.0.2"
  FULL_VERSION = "diarize_worker-#{VERSION}"
end

if __FILE__ == $0
  if ARGV[0] == 'full'
    puts DiarizeWorker::FULL_VERSION
  else
    puts DiarizeWorker::VERSION
  end
end