require 'blinka_reporter/error'

module BlinkaReporter
  class Config
    attr_reader(:commit, :host, :repository, :tag, :team_id, :team_secret)
    DEFAULT_HOST = 'https://www.blinka.app'

    def initialize(
      tag:,
      commit:,
      repository:,
      host: nil,
      team_id:,
      team_secret:
    )
      @commit = commit || find_commit
      @host = host || DEFAULT_HOST
      @repository = repository
      @tag = tag
      @team_id = team_id
      @team_secret = team_secret
    end

    def validate_blinka
      required = [@team_id, @team_secret, @repository]
      if required.include?(nil) || required.include?('')
        raise(BlinkaReporter::Error, <<~EOS)
          Missing configuration, make sure to set --team-id, --team-secret, --repository
        EOS
      end
    end

    def find_commit
      ENV.fetch('HEROKU_TEST_RUN_COMMIT_VERSION', `git rev-parse HEAD`.chomp)
    end
  end
end
