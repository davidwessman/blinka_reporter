require 'minitest/autorun'
require 'minitest/blinka_plugin'
require 'mocha/minitest'
require 'securerandom'

require 'blinka_reporter/client'

class BlinkaReporterMinitestAdapterTest < Minitest::Test
  def test_report_class_method_json
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/example_results.json')
    client.report(data: data, tap: true)
  end

  def test_report_class_method_json2
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/blinka_results.json')
    client.report(data: data, tap: true)
  end

  def test_report_class_method_xml
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/rspec.xml')
    client.report(data: data, tap: true)
  end

  def test_combining_results
    client = BlinkaReporter::Client.new
    data = client.parse(paths: %w[test/rspec.xml test/blinka_results.json])
    client.report(data: data, tap: true)
  end
end
