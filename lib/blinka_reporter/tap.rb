module BlinkaReporter
  class Tap
    # Based on https://github.com/kern/minitest-reporters/blob/master/lib/minitest/reporters/progress_reporter.rb
    # Tries to adhere to https://testanything.org/tap-specification.html
    TAP_COMMENT_PAD = 8
    attr_reader(:data)

    def self.report(data)
      Tap.new(data).report
    end

    def initialize(data)
      results = Array(data[:results])
      return if results.size == 0

      @data = <<~REPORT
        TAP version 13
        1..#{results.size}
        #{test_results(results)}
      REPORT
    end

    def test_results(results)
      report = []
      results.each_with_index do |test, index|
        test_str = "#{test[:path]} - #{test[:name].tr("#", "_")}"
        result = test[:result]
        if result == "pass"
          report << "ok #{index + 1} - #{test_str}"
        elsif result == "skip"
          report << "ok #{index + 1} # skip: #{test_str}"
        elsif result == "fail"
          report << "not ok #{index + 1} - failed: #{test_str}"
          test[:message].split('\n') do |line|
            report << "##{" " * TAP_COMMENT_PAD + line}"
          end
          report << "#"
          Array(test[:backtrace]).each do |line|
            report << "##{" " * TAP_COMMENT_PAD + line}"
          end
          report << ""
        end
      end
      report.join("\n")
    end

    def report
      puts(@data)
    end
  end
end
