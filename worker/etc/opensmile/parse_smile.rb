require 'json'

module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation
      return Math.sqrt(self.sample_variance)
    end

end

lines = File.read(ARGV[0]).split("\n")
json = "[#{lines.join(',')}]"

events = JSON.parse(json)

by_event = events.group_by { |e| e['event'] }

classifications = by_event['classification']

classifications.reject{|c| c['is_final'] != 1 }

classifications.sort_by{|c| "#{c['attribute']}-#{c['classifier']}" }.group_by { |c| "#{c['attribute']}-#{c['classifier']}" }.each{ |label, cs|
  values = cs.map{|c| c['value'] }
  puts "#{label[-9..-1]}\t\t#{values.mean}\t#{values.standard_deviation}"
}

# classifications_by_time = classifications.group_by { |c| c['start_smile'] }

# unless starts.size == ends.size && ends.size == classifications_by_time.keys.size
#   raise "not every segment was classified and our assumption was wrong. shucks."
# end

# segments = starts.zip(ends).map {|start, _end|
#   {start_sec:start['time_sec'], end_sec:_end['time_sec']}
# }

# segments_with_data = segments.zip(classifications_by_time.values).map do |segment, classifications|
#   data = classifications.inject({}) do |data, c|
#     data["#{c['attribute']}-#{c['classifier']}"] = c['value']

#     if probs = c['probabilities']
#       probs.each_with_index do |prob, i|
#         data["#{c['attribute']}-#{c['classifier']}-#{i}-probability"] = prob
#       end
#     end

#     data
#   end
#   segment[:data] = data

#   segment
# end
#
# puts segments_with_data.to_json