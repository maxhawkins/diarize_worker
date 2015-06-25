#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'json'

class GoogleTranscriber

  def self.transcribe(file, options={})
    transcriber = GoogleTranscriber.new(options)
    transcriber.transcribe(file)
  end

  def initialize(options)
    @options = options
    @options[:max_retries] ||= 5
  end

  def transcribe(file)
    retries = 0
    begin
      post_audio_and_parse(file)
    rescue => e
      retries += 1
      if retries <= @options[:max_retries]
        warn "retry #{retries}/#{@options[:max_retries]}"
        sleep (retries ** 2) + 1
        retry
      else
        raise e
      end
    end
  end

  private

  def api_uri
    url = "https://www.google.com/speech-api/v1/"
    url += "recognize?xjerr=1&client=chromium&pfilter=0"
    url += "&lang=#{@options[:language] || "en-US"}"
    url += "&maxresults=#{@options[:max_results] || 10}"
    URI.parse(url)
  end

  def http_client(uri)
    @client ||= Net::HTTP.new(uri.host,uri.port)
    @client.use_ssl = true
    @client
  end

  def post_audio_request(file, uri)
    request = Net::HTTP::Post.new(
    "#{uri.path}?#{uri.query}",
    'Content-Type' => "audio/x-flac; rate=#{@options[:rate] || 16000}"
    )
    request.body = "Content=#{file.read}"
    request
  end

  def post_audio(file)
    uri = api_uri
    warn "POST #{uri}"
    client = http_client(uri)
    request = post_audio_request(file, uri)
    client.request(request)
  end

  def post_audio_and_parse(file)
    response = post_audio(file)
    raise "google request got response code #{response.code}:\n#{response.body}" unless response.kind_of? Net::HTTPSuccess

    json = JSON.parse(response.body)

    json
  end

end

if __FILE__ == $0

  require 'optparse'
  require 'json'

  options = {}
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: transcribe.rb FILE [options]"

    opts.on("--lang [LANG]", String, "audio language") { |v| options[:language] = v }
    opts.on("--results [MAX]", Integer, "maximum results length") { |v| options[:max_results] = v }
    opts.on("--rate [RATE]", Integer, "audio bitrate") { |v| options[:rate] = v }
  end
  opt_parser.parse!

  if filename = ARGV[0]
    warn "transcribing #{filename}"
    file = File.open(filename)
    puts GoogleTranscriber.transcribe(file, options).to_json
  else
    abort opt_parser.to_s
  end

end