require 'blinka_reporter/client'
require 'blinka_reporter/version'

module BlinkaReporter
  class Cli
    def self.run(argv)
      if (argv.index('--help') || -1) >= 0
        puts(<<~EOS)
          blinka_reporter version #{BlinkaReporter::VERSION}

          Options:
          --tap: Flag for outputting test results in TAP-protocol, helpful on Heroku CI.
          --blinka: Flag for reporting test results to blinka.app, requires setting environment:
                    - BLINKA_TEAM_ID
                    - BLINKA_TEAM_SECRET
                    - BLINKA_REPOSITORY
          --path <path>: Path to test results file, works for
                  - ./blinka_results.json blinka json format [default]
                  - ./rspec.xml from https://github.com/sj26/rspec_junit_formatter
        EOS
        return 0
      end

      tap = (argv.index('--tap') || -1) >= 0
      blinka = (argv.index('--blinka') || -1) >= 0
      path = argv_value_for(argv, '--path') || './blinka_results.json'
      BlinkaReporter::Client.report(blinka: blinka, tap: tap, path: path)
      0
    end

    def self.argv_value_for(argv, option_name)
      return unless (index = argv.index(option_name))
      argv[index + 1]
    end
  end
end
