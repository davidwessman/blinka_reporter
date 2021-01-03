require 'minitest'
require 'json'

module Minitest
  def self.plugin_blinka_init(options)
    reporter.reporters << BlinkaPlugin::Reporter.new(options[:io], options)
  end

  def plugin_blinka_options(opts, options); end

  module BlinkaPlugin
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

        result = {
          total_time: total_time,
          nbr_tests: count,
          nbr_assertions: assertions,
          seed: options[:seed],
          results:
            tests.map { |test_result| BlinkaMinitest.new(test_result).report }
        }

        File.open('blinka_results.json', 'w+') do |file|
          file.write(JSON.pretty_generate(result))
        end
        puts
        puts('Test results written to `./blinka_results.json`')
      end
    end
  end
end
