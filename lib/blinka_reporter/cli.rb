require 'blinka_reporter/client'
require 'blinka_reporter/version'

module BlinkaReporter
  class Cli
    def self.run(argv)
      if (argv.index('--help') || -1) >= 0
        puts(<<~EOS)
          blinka_reporter version #{BlinkaReporter::VERSION}

          Options:
          --path <path>: Path to test results file, can be supplied multiple times to combine results
            - ./blinka_results.json blinka json format
            - ./rspec.xml from https://github.com/sj26/rspec_junit_formatter

          --tap: Flag for outputting test results in TAP-protocol, helpful on Heroku CI
          --blinka: Flag for reporting test results to blinka.app, requires also supplying:
            - --team-id
            - --team-secret
            - --repository
            - --commit
          --team-id <team-id>: Blinka team id, only used with --blinka
          --team-secret <team-secret>: Blinka team secret, only used with --blinka
          --commit <commit>: The commit hash to report
          --tag <tag>: The tag for the run, for example to separate a test matrix
          --repository <repository>: The Github repository
          --host <host>: Override Blink host to send report

        EOS
        return 0
      end

      tap = (argv.index('--tap') || -1) >= 0

      paths = argv_value_for(argv, '--path')

      blinka = (argv.index('--blinka') || -1) >= 0
      commit = argv_value_for(argv, '--commit')&.first
      repository = argv_value_for(argv, '--repository')&.first
      tag = argv_value_for(argv, '--tag')&.first
      team_id = argv_value_for(argv, '--team-id')&.first
      team_secret = argv_value_for(argv, '--team-secret')&.first
      host = argv_value_for(argv, '--host')&.first

      client = BlinkaReporter::Client.new
      data = client.parse(paths: paths)
      config =
        BlinkaReporter::Config.new(
          tag: tag,
          commit: commit,
          team_id: team_id,
          team_secret: team_secret,
          repository: repository,
          host: host
        )
      client.report(data: data, config: config, tap: tap, blinka: blinka)
    end

    def self.argv_value_for(argv, option_name)
      argv
        .each_index
        .select { |index| argv[index] == option_name }
        .map { |index| argv[index + 1] }
    end
  end
end
