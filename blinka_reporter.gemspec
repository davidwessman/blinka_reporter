require_relative "lib/blinka_reporter/version"

Gem::Specification.new do |gem|
  gem.authors = ["David Wessman"]
  gem.description =
    "Use to format test results from Minitest to use with Blinka."
  gem.email = "david@wessman.co"
  gem.homepage = "https://github.com/davidwessman/blinka_reporter"
  gem.license = "MIT"
  gem.summary = "Format tests for Blinka"

  gem.metadata = {
    "homepage_uri" => "https://github.com/davidwessman/blinka_reporter",
    "bug_tracker_uri" =>
      "https://github.com/davidwessman/blinka_reporter/issues",
    "documentation_uri" => "https://github.com/davidwessman/blinka_reporter",
    "changelog_uri" =>
      "https://github.com/davidwessman/blinka_reporter/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/davidwessman/blinka_reporter",
    "rubygems_mfa_required" => "true"
  }

  gem.files =
    Dir.chdir(File.expand_path("..", __FILE__)) do
      `git ls-files -z`.split("\x0")
        .reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  gem.name = "blinka-reporter"
  gem.version = BlinkaReporter::VERSION
  gem.executables = ["blinka_reporter"]
  gem.require_path = ["lib"]

  gem.add_dependency("ox", "~> 2")
  gem.add_development_dependency("dotenv", "~> 3.0.0")
  gem.add_development_dependency("minitest", ">= 5", "< 7")
  gem.add_development_dependency("mocha", "~> 3.0")
  gem.add_development_dependency("rake", "~> 13")
  gem.add_development_dependency("standard")
end
