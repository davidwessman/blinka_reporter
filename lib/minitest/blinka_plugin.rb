require 'minitest'
require 'json'
require 'blinka_reporter/minitest_adapter'
require 'blinka_reporter/client'

module Minitest
  def self.plugin_blinka_init(options)
    reporter.reporters << BlinkaPlugin::Reporter.new(options[:io], options)
  end

  def plugin_blinka_options(opts, options); end

  module BlinkaPlugin
    REPORT_PATH = 'blinka_results.json'.freeze
    class Reporter < Minitest::StatisticsReporter
      attr_accessor :tests

      def initialize(io = $stdout, options = {})
        super
        self.tests = []
      end

      def record(test)
        super
        tests << test
      end

      def report
        super

        json_report(append: !ENV['BLINKA_APPEND'].nil?) if ENV['BLINKA_JSON']
      rescue BlinkaReporter::Client::BlinkaReporter::Error => error
        puts(error)
      end

      private

      def json_report(append:)
        result = {
          total_time: total_time,
          nbr_tests: count,
          nbr_assertions: assertions,
          seed: options[:seed],
          results:
            tests.map do |test_result|
              BlinkaReporter::MinitestAdapter.new(test_result).report
            end
        }
        result = append_previous(result) if append

        File.open(REPORT_PATH, 'w+') do |file|
          file.write(JSON.pretty_generate(result))
        end

        puts
        puts("Test results written to `#{REPORT_PATH}`")
      end

      private

      def parse_report
        return unless File.exist?(REPORT_PATH)
        JSON.parse(File.read(REPORT_PATH), symbolize_names: true)
      end

      def append_previous(result)
        previous = parse_report
        return if previous.nil?
        return if result[:commit] != previous[:commit]
        return if result[:tag] != previous[:tag]

        result[:total_time] += previous[:total_time] || 0
        result[:nbr_tests] += previous[:nbr_tests] || 0
        result[:nbr_assertions] += previous[:nbr_assertions] || 0
        result[:results] += previous[:results] || []
        result
      end
    end
  end
end
