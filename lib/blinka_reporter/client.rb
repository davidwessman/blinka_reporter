require "ox"
require "json"

require "blinka_reporter/error"
require "blinka_reporter/tap"

module BlinkaReporter
  class Client
    def parse(paths: nil)
      paths ||= ["./blinka_results.json"]
      paths = Array(paths)
      paths.each do |path|
        unless File.exist?(path)
          raise(
            BlinkaReporter::Error,
            "Could not find #{path}, make sure the path is correct."
          )
        end
      end

      merge_results(
        paths.map do |path|
          if path.end_with?(".xml")
            parse_xml(path: path)
          elsif path.end_with?(".json")
            parse_json(path: path)
          else
            raise(
              BlinkaReporter::Error,
              "Unknown format of #{path}, needs to be .json or .xml"
            )
          end
        end
      )
    end

    def report(data:, tap: false)
      BlinkaReporter::Tap.report(data) if tap
      0
    end

    private

    def merge_results(data_array)
      data = { total_time: 0, nbr_tests: 0, nbr_assertions: 0, results: [] }
      data_array.each do |result|
        data[:total_time] += result[:total_time] || 0
        data[:nbr_tests] += result[:nbr_tests] || 0
        data[:nbr_assertions] += result[:nbr_assertions] || 0
        data[:results] += result[:results] || []
      end
      data
    end

    def parse_json(path:)
      JSON.parse(File.open(path).read, symbolize_names: true)
    end

    def parse_xml(path:)
      data = Ox.load_file(path, { symbolize_keys: true, skip: :skip_none })
      test_suite = data.root
      unless test_suite.name == "testsuite"
        raise("Root element is not <testsuite>, instead #{test_suite.name}")
      end

      properties = test_suite.nodes.select { |node| node.name == "properties" }
      test_cases = test_suite.nodes.select { |node| node.name == "testcase" }
      {
        nbr_tests: Integer(test_suite.tests || 0),
        total_time: Float(test_suite.time),
        seed: xml_seed(properties),
        results: xml_test_cases(test_cases)
      }
    end

    def xml_seed(ox_properties)
      ox_properties.each do |property|
        property.nodes.each do |node|
          return node.attributes[:value] if node.attributes[:name] == "seed"
        end
      end
      nil
    end

    # Kind is extracted from the second part of spec.models.customer_spec
    def xml_test_cases(test_cases)
      test_cases.map do |test_case|
        result = {
          kind: Array(test_case.attributes[:classname]&.split("."))[1],
          name: test_case.attributes[:name],
          path: test_case.attributes[:file]&.delete_prefix("./"),
          time: Float(test_case.attributes[:time] || 0)
        }
        if test_case.nodes.any?
          skipped = test_case.nodes.any? { |node| node.name == "skipped" }
          result[:result] = "skip" if skipped
          failure =
            test_case.nodes.select { |node| node.name == "failure" }.first
          if failure
            result[:result] = "fail"

            # Needs to be double quotation marks to work properly
            result[:backtrace] = failure.text.split("\n")
            result[:image] = get_image_path(result[:backtrace])
            result[:message] = failure.attributes[:message]
          end
        else
          result[:result] = "pass"
        end
        result
      end
    end

    def get_image_path(backtrace)
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
