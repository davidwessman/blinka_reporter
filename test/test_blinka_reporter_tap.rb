require "minitest/autorun"
require "mocha/minitest"
require "blinka_reporter/tap"

class BlinkaReporterTapTest < Minitest::Test
  def test_tap_failures
    data = {
      results: [
        { path: "first/test.rb", name: "test_tap_pass", result: "pass" },
        { path: "first/test.rb", name: "test_tap_skip", result: "skip" },
        {
          path: "first/test.rb",
          name: "test_tap_fail",
          result: "fail",
          message: 'this\nis\nthe\nerror\nmessage what',
          backtrace: [
            "one",
            "two",
            'this is the next line\nshould it handle newlines?'
          ]
        }
      ]
    }

    tap = BlinkaReporter::Tap.new(data)
    report = tap.data.split("\n")
    assert_equal("TAP version 13", report[0])
    assert_equal("1..3", report[1])
    assert_equal("ok 1 - first/test.rb - test_tap_pass", report[2])
    assert_equal("ok 2 # skip: first/test.rb - test_tap_skip", report[3])
    assert_equal("not ok 3 - failed: first/test.rb - test_tap_fail", report[4])

    report[5..].each { |line| assert(line.start_with?("#")) }
  end
end
