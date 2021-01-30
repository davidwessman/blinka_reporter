require 'rake/testtask'
require './lib/blinka_client'
require 'dotenv/load'

Rake::TestTask.new { |t| t.libs << 'test' }

desc('Run tests')
task(default: :test)

namespace(:blinka) do
  desc('Report test results to blinka')
  task('report') { BlinkaClient.new.report }
end
