class BlinkaMinitest
  def initialize(test_result)
    @test_result = test_result
  end

  def path
    @path ||= source_location.first.gsub(Dir.getwd, '').delete_prefix('/')
  end

  def line
    @line ||= source_location.last
  end

  # Handle broken API in Minitest between 5.10 and 5.11
  # https://github.com/minitest-reporters/minitest-reporters/blob/e9092460b5a5cf5ca9eb375428217cbb2a7f6dbb/lib/minitest/reporters/default_reporter.rb#L159
  def source_location
    @source_location ||=
      if @test_result.respond_to?(:klass)
        @test_result.source_location
      else
        @test_result.method(@test_result.name).source_location
      end
  end

  def kind
    parts = self.path.gsub('test/', '').split('/')
    parts.length > 1 ? parts.first : 'general'
  end

  def message
    failure = @test_result.failure
    return unless failure
    "#{failure.error.class}: #{failure.error.message}"
  end

  def backtrace
    return unless @test_result.failure
    Minitest.filter_backtrace(@test_result.failure.backtrace)
  end

  def result
    if @test_result.error?
      :error
    elsif @test_result.skipped?
      :skip
    elsif @test_result.failure
      :fail
    else
      :pass
    end
  end

  def time
    @test_result.time
  end

  def name
    @test_result.name
  end

  def image
    return unless kind == 'system'

    image_path = "./tmp/screenshots/failures_#{name}.png"
    return unless File.exist?(image_path)

    image_path
  end

  def report
    {
      backtrace: backtrace,
      message: message,
      line: line,
      image: image,
      kind: kind,
      name: name,
      path: path,
      result: result,
      time: time
    }.compact
  end
end
