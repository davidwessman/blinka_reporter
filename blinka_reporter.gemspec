Gem::Specification.new do |spec|
  spec.name = 'blinka-reporter'
  spec.version = '0.2.1'
  spec.date = '2021-02-08'
  spec.summary = 'Format tests for Blinka'
  spec.description =
    'Use to format test results from Minitest to use with Blinka.'
  spec.authors = ['David Wessman']
  spec.email = 'david@wessman.co'
  spec.files = %w[
    lib/blinka_minitest.rb
    lib/minitest/blinka_plugin.rb
    lib/blinka_client.rb
  ]
  spec.homepage = 'https://github.com/davidwessman/blinka_reporter'
  spec.license = 'MIT'
  spec.add_dependency('httparty', '~> 0.18.1')
  spec.add_dependency('mimemagic', '~> 0.3.5')
  spec.add_development_dependency('dotenv', '~> 2.7.6')
  spec.add_development_dependency('minitest', '~> 5.0')
  spec.add_development_dependency('mocha', '~> 1.12')
  spec.add_development_dependency('rake', '~> 13')
end
