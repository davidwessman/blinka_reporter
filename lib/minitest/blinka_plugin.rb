require 'minitest'
require 'json'
require 'blinka_minitest'
require 'blinka_client'

module Minitest
  def self.plugin_blinka_init(options)
    reporter.reporters << BlinkaPlugin::Reporter.new(options[:io], options)
  end

  def plugin_blinka_options(opts, options); end

  module BlinkaPlugin
    TAP_COMMENT_PAD = 8
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

        tap_report if ENV['BLINKA_TAP']
        json_report if ENV['BLINKA_JSON'] || ENV['BLINKA_REPORT']
        BlinkaClient.new.report if ENV['BLINKA_REPORT']
      rescue BlinkaClient::BlinkaError => error
        puts(error)
      end

      private

      def json_report
        result = {
          total_time: total_time,
          nbr_tests: count,
          nbr_assertions: assertions,
          commit: find_commit,
          tag: ENV.fetch('BLINKA_TAG', ''),
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

      # Based on https://github.com/kern/minitest-reporters/blob/master/lib/minitest/reporters/progress_reporter.rb
      # Tries to adhere to https://testanything.org/tap-specification.html
      def tap_report
        puts
        puts('TAP version 13')
        puts("1..#{tests.length}")
        tests.each_with_index do |test, index|
          blinka = BlinkaMinitest.new(test)
          test_str = "#{blinka.path} - #{test.name.tr('#', '_')}"
          if test.passed?
            puts "ok #{index + 1} - #{test_str}"
          elsif test.skipped?
            puts "ok #{index + 1} # skip: #{test_str}"
          elsif test.failure
            puts "not ok #{index + 1} - failed: #{test_str}"
            blinka.message.each_line { |line| print_padded_comment(line) }

            # test.failure.message.each_line { |line| print_padded_comment(line) }
            unless test.failure.is_a?(MiniTest::UnexpectedError)
              blinka.backtrace.each { |line| print_padded_comment(line) }
            end
            puts
          end
        end
      end

      def print_padded_comment(line)
        puts "##{' ' * TAP_COMMENT_PAD + line}"
      end

      def find_commit
        ENV.fetch(
          'BLINKA_COMMIT',
          ENV.fetch(
            'HEROKU_TEST_RUN_COMMIT_VERSION',
            `git rev-parse HEAD`.chomp
          )
        )
      end
    end
  end
end
