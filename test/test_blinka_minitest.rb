require 'minitest/autorun'
require 'mocha/minitest'
require 'blinka_reporter/minitest_adapter'

class MinitestAdapterTest < Minitest::Test
  def test_source_location
    test_result = Minitest::Result.new('test_source_location')
    test_result.source_location = [
      "#{__dir__}/model/test_blinka_minitest.rb",
      10
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_equal('test/model/test_blinka_minitest.rb', blinka.path)
  end

  def test_kind
    test_result = Minitest::Result.new('test_kind')
    test_result.source_location = [
      "#{__dir__}/model/test_blinka_minitest.rb",
      10
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_equal('model', blinka.kind)
  end

  def test_kind_no_folder
    test_result = Minitest::Result.new('test_kind_no_folder')
    test_result.source_location = ["#{__dir__}/test_blinka_minitest.rb", 10]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_equal('general', blinka.kind)
  end

  def test_message
    test_result = Minitest::Result.new('test')
    test_result.failures = [
      Minitest::Assertion.new('Expected nil to not be nil')
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_equal(
      'Minitest::Assertion: Expected nil to not be nil',
      blinka.message
    )
  end

  def test_message_no_failure
    test_result = Minitest::Result.new('test')
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_nil(blinka.message)
  end

  def test_backtrace
    test_result = Minitest::Result.new('test')
    backtrace = [
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/assertions.rb:183:in `assert'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/assertions.rb:303:in `assert_nil'",
      "test/test_blinka_minitest.rb:54:in `test_backtrace'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:195:in `capture_exceptions'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:95:in `block (2 levels) in run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:272:in `time_it'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:94:in `block in run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:367:in `on_signal'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:211:in `with_info_handler'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb:93:in `run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:1029:in `run_one_method'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:341:in `run_one_method'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:328:in `block (2 levels) in run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:327:in `each'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:327:in `block in run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:367:in `on_signal'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:354:in `with_info_handler'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:164:in `block in __run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:164:in `map'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:164:in `__run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:141:in `run'",
      "/Users/davidwessman/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb:68:in `block in autorun'"
    ]
    test_result.failures = [
      Minitest::Assertion.new('Expected nil to not be nil')
    ]
    test_result.failure.set_backtrace(backtrace)
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_equal(
      ["test/test_blinka_minitest.rb:54:in `test_backtrace'"],
      blinka.backtrace
    )
  end

  def test_backtrace_no_failure
    test_result = Minitest::Result.new('test')
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_nil(blinka.backtrace)
  end

  def test_result
    test_result = Minitest::Result.new('test')
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(:pass, blinka.result)

    test_result.failures = [
      Minitest::Assertion.new('Expected nil to not be nil')
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(:fail, blinka.result)

    test_result.failures = [Minitest::Skip.new('Skipped it all')]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(:skip, blinka.result)

    test_result.failures = [
      Minitest::UnexpectedError.new('This should not have happened')
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(:error, blinka.result)
  end

  def test_image
    test_result = Minitest::Result.new('test')
    test_result.source_location = [
      "#{__dir__}/system/test_blinka_minitest.rb",
      10
    ]
    File.expects(:exist?).returns(true)
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    refute_nil(blinka.image)
  end

  def test_image_no_file
    test_result = Minitest::Result.new('test')
    test_result.source_location = [
      "#{__dir__}/system/test_blinka_minitest.rb",
      10
    ]
    File.expects(:exist?).returns(false)
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)

    assert_nil(blinka.image)
  end

  def test_report
    test_result = Minitest::Result.new('test')
    test_result.time = 0.000025
    test_result.failures = [
      Minitest::Assertion.new('Expected nil to not be nil')
    ]
    test_result.failure.set_backtrace(
      ["test/model/test_blinka_minitest.rb:54:in `test_backtrace'"]
    )
    test_result.source_location = [
      "#{__dir__}/model/test_blinka_minitest.rb",
      10
    ]
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(
      %i[backtrace message line kind name path result time].sort,
      blinka.report.keys.sort
    )
  end

  def test_report_with_image
    test_result = Minitest::Result.new('test')
    test_result.time = 0.000025
    test_result.failures = [
      Minitest::Assertion.new('Expected nil to not be nil')
    ]
    test_result.failure.set_backtrace(
      ["test/system/test_blinka_minitest.rb:54:in `test_backtrace'"]
    )
    test_result.source_location = [
      "#{__dir__}/system/test_blinka_minitest.rb",
      10
    ]
    File.expects(:exist?).at_least_once.returns(true)
    blinka = BlinkaReporter::MinitestAdapter.new(test_result)
    assert_equal(
      %i[backtrace message line kind image name path result time].sort,
      blinka.report.keys.sort
    )
  end
end
