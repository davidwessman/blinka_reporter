require "minitest"
require "json"
require "blinka_reporter/minitest_adapter"
require "blinka_reporter/client"

module Minitest
  def self.plugin_blinka_init(options)
    reporter.reporters << BlinkaPlugin::Reporter.new(options[:io], options)
  end

  def plugin_blinka_options(opts, options)
  end

  module BlinkaPlugin
    class Reporter < Minitest::StatisticsReporter
      attr_accessor :tests

      def record(test)
        super
        self.tests ||= []
        tests << test
      end

      def report
        super

        json_report
      rescue BlinkaReporter::Error => error
        puts(error)
      end

      private

      def json_report
        report_path = ENV["BLINKA_PATH"]
        return if report_path.nil? || report_path.eql?("")

        result = {
          total_time: total_time,
          nbr_tests: count,
          nbr_assertions: assertions,
          seed: options[:seed],
          results:
            tests&.map do |test_result|
              BlinkaReporter::MinitestAdapter.new(test_result).report
            end || []
        }

        if ENV["BLINKA_APPEND"] == "true" && File.exist?(report_path)
          existing =
            JSON.parse(File.open(report_path).read, symbolize_names: true)
          result[:results] = existing[:results] + result[:results]
          result[:nbr_tests] = existing[:nbr_tests] + result[:nbr_tests]
          result[:nbr_assertions] = existing[:nbr_assertions] +
            result[:nbr_assertions]
          result[:total_time] = existing[:total_time] + result[:total_time]
        end

        File.open(report_path, "w+") do |file|
          file.write(JSON.pretty_generate(result))
        end

        puts
        puts("Test results written to `#{report_path}`")
      end
    end
  end
end
