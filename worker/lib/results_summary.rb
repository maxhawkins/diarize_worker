#!/usr/bin/env ruby

require "json"
require_relative "diarize_worker/version"

if ARGV.size == 2
  id, results_dir = ARGV

  file = File.join(results_dir, "transcription.json")
  transcription = File.read(file)

  error_count = transcription.scan(/null/).size

  puts ({id:id, error_count:error_count}).to_json
else
  warn "Usage: results_summary.rb RECORDING_ID RESULTS_DIR"
  exit 1
end