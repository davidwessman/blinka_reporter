require "minitest/autorun"
require "mocha/minitest"

require "blinka_reporter/client"

class BlinkaParsingTest < Minitest::Test
  def test_parse_xml
    data = BlinkaReporter::Client.new.parse(paths: "test/rspec.xml")

    assert_equal(54, data[:results].size)

    first_failure = data[:results][50]
    refute_nil(first_failure)
    assert_equal("fail", first_failure[:result])
    assert_equal(7, first_failure[:backtrace].size)
    refute_nil(first_failure[:image])

    last_failure = data[:results][53]
    refute_nil(last_failure)
    assert_equal("fail", last_failure[:result])
    assert_equal(9, last_failure[:backtrace].size)
    refute_nil(last_failure[:image])
  end

  def test_parse_json
    data = BlinkaReporter::Client.new.parse(paths: "test/blinka_results.json")

    assert_equal(75, data[:results].size)

    error = data[:results][73]
    refute_nil(error)
    assert_equal("error", error[:result])
    assert_equal(2, error[:backtrace].size)
    refute_nil(error[:image])

    failure = data[:results][74]
    refute_nil(failure)
    assert_equal("fail", failure[:result])
    assert_equal(1, failure[:backtrace].size)
    refute_nil(failure[:image])
  end

  def test_combining_results
    data =
      BlinkaReporter::Client.new.parse(
        paths: %w[test/rspec.xml test/blinka_results.json]
      )

    assert_equal(54 + 75, data[:results].size)

    specs = data[:results].count { |result| result[:path].include?("spec/") }
    tests = data[:results].count { |result| result[:path].include?("test/") }

    assert_equal(54, specs)
    assert_equal(75, tests)
  end
end
