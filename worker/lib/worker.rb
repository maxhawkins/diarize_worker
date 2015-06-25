#!/usr/bin/env ruby

require 'redis'
require_relative "diarize_worker/version"

module DiarizeWorker

  WORK_QUEUE = "diarize_worker_queue-#{VERSION}"
  PROCESSING_QUEUE = "diarize_worker_processing-#{VERSION}"
  DONE_QUEUE = "diarize_worker_done-#{VERSION}"

  WORKER_DIR = File.join(File.dirname(__FILE__), "..")

  class Worker
    class << self

      attr_accessor :current_conference

      def redis_url
        ENV['REDIS_URL'] or raise "must supply REDIS_URL"
      end

      def client
        @client ||= Redis.new(url:redis_url)
      end

      def work
        while current_conference = next_conference

          puts `make #{current_conference}`

          if $?.to_i == 0
            client.pipelined do
              client.lpush DONE_QUEUE, current_conference
              client.lrem PROCESSING_QUEUE, 0, current_conference
            end
            current_conference = nil
          end

        end
      end

      def clean_up
        if current_conference
          warn "cleaning up conference #{current_conference}"
          client.pipelined do
            client.lpush WORK_QUEUE, current_conference
            client.lpush PROCESSING_QUEUE, current_conference
          end
        end
      end

      private

      def next_conference
        puts "Blocking on #{WORK_QUEUE}"
        conference = client.brpoplpush WORK_QUEUE, PROCESSING_QUEUE
        puts "Grabbed conference #{conference}"
        conference
      end

    end
  end

end