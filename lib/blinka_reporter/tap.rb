module BlinkaReporter
  class Tap
    # Based on https://github.com/kern/minitest-reporters/blob/master/lib/minitest/reporters/progress_reporter.rb
    # Tries to adhere to https://testanything.org/tap-specification.html
    TAP_COMMENT_PAD = 8

    def self.report(data)
      Tap.new(data).report
    end

    def initialize(data)
      @data = data
    end

    def report
      tests = @data[:results]
      puts
      puts('TAP version 13')
      puts("1..#{tests.size}")
      tests.each_with_index do |test, index|
        test_str = "#{test[:path]} - #{test[:name].tr('#', '_')}"
        result = test[:result]
        if result == 'pass'
          puts "ok #{index + 1} - #{test_str}"
        elsif result == 'skip'
          puts "ok #{index + 1} # skip: #{test_str}"
        elsif result == 'fail'
          puts "not ok #{index + 1} - failed: #{test_str}"
          test[:message].each_line { |line| print_padded_comment(line) }

          Array(test[:backtrace]).each { |line| print_padded_comment(line) }
          puts
        end
      end
    end

    def print_padded_comment(line)
      puts "##{' ' * TAP_COMMENT_PAD + line}"
    end
  end
end
