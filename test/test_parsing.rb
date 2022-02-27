require 'minitest/autorun'
require 'mocha/minitest'

require 'blinka_reporter/client'

class BlinkaParsingTest < Minitest::Test
  def test_parse_xml
    data = BlinkaReporter::Client.parse_xml(path: 'test/rspec.xml')

    assert_equal(54, data[:results].size)

    first_failure = data[:results][50]
    refute_nil(first_failure)
    assert_equal('fail', first_failure[:result])
    assert_equal(7, first_failure[:backtrace].size)
    refute_nil(first_failure[:image])

    last_failure = data[:results][53]
    refute_nil(last_failure)
    assert_equal('fail', last_failure[:result])
    assert_equal(9, last_failure[:backtrace].size)
    refute_nil(last_failure[:image])
  end
end
