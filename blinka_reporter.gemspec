require_relative 'lib/blinka_reporter/version'

Gem::Specification.new do |gem|
  gem.authors = ['David Wessman']
  gem.description =
    'Use to format test results from Minitest to use with Blinka.'
  gem.email = 'david@wessman.co'
  gem.homepage = 'https://github.com/davidwessman/blinka_reporter'
  gem.license = 'MIT'
  gem.summary = 'Format tests for Blinka'

  gem.metadata = {
    'homepage_uri' => 'https://github.com/davidwessman/blinka_reporter',
    'bug_tracker_uri' =>
      'https://github.com/davidwessman/blinka_reporter/issues',
    'documentation_uri' => 'https://github.com/davidwessman/blinka_reporter',
    'changelog_uri' =>
      'https://github.com/davidwessman/blinka_reporter/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/davidwessman/blinka_reporter',
    'rubygems_mfa_required' => 'true'
  }

  gem.files = %w[
    lib/blinka_minitest.rb
    lib/minitest/blinka_plugin.rb
    lib/blinka_client.rb
    lib/blinka_reporter/version.rb
  ]
  gem.name = 'blinka-reporter'
  gem.version = BlinkaReporter::VERSION

  gem.add_dependency('httparty', '~> 0.18')
  gem.add_development_dependency('dotenv', '~> 2.7.6')
  gem.add_development_dependency('minitest', '~> 5.0')
  gem.add_development_dependency('mocha', '~> 1.12')
  gem.add_development_dependency('rake', '~> 13')
  gem.add_development_dependency('webmock', '~> 3.11')
end
