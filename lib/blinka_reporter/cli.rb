require "blinka_reporter/client"
require "blinka_reporter/version"

module BlinkaReporter
  class Cli
    def self.run(argv)
      if (argv.index("--help") || -1) >= 0
        puts(<<~EOS)
          blinka_reporter version #{BlinkaReporter::VERSION}

          Options:
          --path <path>: Path to test results file, can be supplied multiple times to combine results
            - ./blinka_results.json blinka json format
            - ./rspec.xml from https://github.com/sj26/rspec_junit_formatter

          --tap: Flag for outputting test results in TAP-protocol, helpful on Heroku CI
        EOS
        return 0
      end

      tap = (argv.index("--tap") || -1) >= 0

      paths = argv_value_for(argv, "--path")

      client = BlinkaReporter::Client.new
      data = client.parse(paths: paths)
      client.report(data: data, tap: tap)
    end

    def self.argv_value_for(argv, option_name)
      argv
        .each_index
        .select { |index| argv[index] == option_name }
        .map { |index| argv[index + 1] }
    end
  end
end
