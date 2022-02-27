require 'httparty'
require 'ox'

require 'blinka_reporter/blinka'
require 'blinka_reporter/config'
require 'blinka_reporter/error'
require 'blinka_reporter/tap'

module BlinkaReporter
  class Client
    def initialize
      @config = BlinkaReporter::Config.new
    end

    def report(path: './blinka_results.json', blinka: false, tap: false)
      unless File.exist?(path)
        raise(
          BlinkaReporter::Error,
          "Could not find #{path}, was it generated when running the tests?"
        )
      end

      data =
        if path.end_with?('.xml')
          self.class.parse_xml(path: path)
        elsif path.end_with?('.json')
          self.class.parse_json(path: path)
        else
          raise(
            BlinkaReporter::Error,
            "Unknown format of #{path}, needs to be .json or .xml"
          )
        end

      BlinkaReporter::Tap.report(data) if tap
      BlinkaReporter::Blinka.report(config: @config, data: data) if blinka
      0
    end

    def self.report(path:, tap: false, blinka: false)
      Client.new.report(path: path, tap: tap, blinka: blinka)
    end

    def self.parse_json(path:)
      JSON.parse(File.open(path).read, symbolize_names: true)
    end

    def self.parse_xml(path:)
      data = Ox.load_file(path, { symbolize_keys: true, skip: :skip_none })
      test_suite = data.root
      unless test_suite.name == 'testsuite'
        raise("Root element is not <testsuite>, instead #{test_suite.name}")
      end

      properties = test_suite.nodes.select { |node| node.name == 'properties' }
      test_cases = test_suite.nodes.select { |node| node.name == 'testcase' }
      {
        nbr_tests: Integer(test_suite.tests || 0),
        total_time: Float(test_suite.time),
        seed: xml_seed(properties),
        results: xml_test_cases(test_cases)
      }
    end

    def self.xml_seed(ox_properties)
      ox_properties.each do |property|
        property.nodes.each do |node|
          return node.attributes[:value] if node.attributes[:name] == 'seed'
        end
      end
      nil
    end

    # Kind is extracted from the second part of spec.models.customer_spec
    def self.xml_test_cases(test_cases)
      test_cases.map do |test_case|
        result = {
          kind: Array(test_case.attributes[:classname]&.split('.'))[1],
          name: test_case.attributes[:name],
          path: test_case.attributes[:file]&.delete_prefix('./'),
          time: Float(test_case.attributes[:time] || 0)
        }
        if test_case.nodes.any?
          skipped = test_case.nodes.any? { |node| node.name == 'skipped' }
          result[:result] = 'skip' if skipped
          failure =
            test_case.nodes.select { |node| node.name == 'failure' }.first
          if failure
            result[:result] = 'fail'

            # Needs to be double quotation marks to work properly
            result[:backtrace] = failure.text.split("\n")
            result[:image] = get_image_path(result[:backtrace])
            result[:message] = failure.attributes[:message]
          end
        else
          result[:result] = 'pass'
        end
        result
      end
    end

    def self.get_image_path(backtrace)
      backtrace.each do |text|
        path = /^(\[Screenshot\]|\[Screenshot Image\]):\s([\S]*)$/.match(text)
        next if path.nil?
        path = path[-1]
        next unless File.exist?(path)
        return path
      end
      nil
    end
  end
end
