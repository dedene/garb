module Garb
  class ReportResponse
    
    def initialize(response_body, instance_klass = OpenStruct)
      @data = response_body
      @instance_klass = instance_klass
    end

    def results
      if @results.nil?
        @results = ResultSet.new(parse)
        @results.total_results = parse_total_results
        @results.sampled = parse_sampled_flag
      end

      @results
    end

    def sampled?
    end

    def parse
      entries.map do |entry|
        @instance_klass.new(Hash[
          entry.map {|v| [Garb.from_ga(v['name']), v['value']]}
        ])
      end
    end

    def entries
      @entries = []
      if feed?
        parsed_data['rows'].each do |row|
          data = []
          parsed_data['columnHeaders'].each_with_index do |column,i|
            data << {'name' => column['name'], 'value' => row[i]}
          end
          @entries << data
        end
      else        
        []
      end
      return @entries
    end

    def parse_total_results
      if feed?
        @totalsForAllResults = []
        parsed_data['totalsForAllResults'].each do |key,value|
          @totalsForAllResults << {'name' => key, 'value' => value}
        end
        @instance_klass.new(Hash[
          @totalsForAllResults.map {|v| [Garb.from_ga(v['name']), v['value']]}
        ])
      else
        0
      end
    end

    def parse_sampled_flag
      feed? ? parsed_data['containsSampledData'] : false
    end

    def parsed_data
      @parsed_data ||= JSON.parse(@data)
    end

    def feed?
      (parsed_data['columnHeaders'].length > 0 || parsed_data['rows'].length > 0)
    end
  end
end
