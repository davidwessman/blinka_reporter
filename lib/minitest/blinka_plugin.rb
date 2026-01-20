require "minitest"
require "json"
require "blinka_reporter/minitest_adapter"
require "blinka_reporter/client"

module Minitest
  def self.plugin_blinka_init(options)
    reporter << BlinkaPlugin::Reporter.new(options[:io], options)
  end

  def self.plugin_blinka_options(opts, options)
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
            JSON.parse(File.read(report_path), symbolize_names: true)
          result[:results] = existing[:results] + result[:results]
          result[:nbr_tests] = existing[:nbr_tests] + result[:nbr_tests]
          result[:nbr_assertions] = existing[:nbr_assertions] +
            result[:nbr_assertions]
          result[:total_time] = existing[:total_time] + result[:total_time]
        end

        File.write(report_path, JSON.pretty_generate(result))

        puts
        puts("Test results written to `#{report_path}`")
      end
    end
  end
end

if Minitest.respond_to?(:extensions)
  registered = Minitest.extensions.map(&:to_s).include?("blinka")

  unless registered
    if Minitest.respond_to?(:register_plugin)
      Minitest.register_plugin(:blinka)
    else
      Minitest.extensions << "blinka"
    end
  end
end
