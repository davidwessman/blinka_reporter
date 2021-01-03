class BlinkaMinitest
  attr_reader(:test_result)
  def initialize(test_result)
    @test_result = test_result
  end

  def path
    current_dir = Dir.getwd
    test_result.source_location.first.gsub(current_dir, '').delete_prefix('/')
  end

  def kind
    parts = self.path.gsub('test/', '').split('/')
    parts.length > 1 ? parts.first : 'general'
  end

  def message
    failure = test_result.failure
    return unless failure
    "#{failure.error.class}: #{failure.error.message}"
  end

  def backtrace
    return unless test_result.failure
    Minitest.filter_backtrace(test_result.failure.backtrace)
  end

  def result
    if test_result.error?
      :error
    elsif test_result.skipped?
      :skip
    elsif test_result.failure
      :failed
    else
      :pass
    end
  end

  def line
    current_backtrace = backtrace
    return if current_backtrace.nil?

    row =
      current_backtrace
        .map { |row| row.split(':')[0..1] }
        .detect { |row| row[0] == path }

    return if row.nil?
    row[1].to_i
  end

  def time
    test_result.time
  end

  def name
    test_result.name
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
