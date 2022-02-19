require 'blinka_reporter/error'

module BlinkaReporter
  class Config
    attr_reader(:commit, :host, :repository, :tag, :team_id, :team_secret)

    def initialize
      @commit = find_commit
      @host = ENV.fetch('BLINKA_HOST', 'https://www.blinka.app')
      @repository = ENV.fetch('BLINKA_REPOSITORY', nil)
      @tag = ENV.fetch('BLINKA_TAG', nil)
      @team_id = ENV.fetch('BLINKA_TEAM_ID', nil)
      @team_secret = ENV.fetch('BLINKA_TEAM_SECRET', nil)
    end

    def validate_blinka
      if @team_id.nil? || @team_secret.nil? || @repository.nil?
        raise(BlinkaReporter::Error, <<~EOS)
          Missing configuration, make sure to set required environment variables:
          - BLINKA_TEAM_ID
          - BLINKA_TEAM_SECRET
          - BLINKA_REPOSITORY
          EOS
      end
    end

    def find_commit
      ENV.fetch(
        'BLINKA_COMMIT',
        ENV.fetch('HEROKU_TEST_RUN_COMMIT_VERSION', `git rev-parse HEAD`.chomp)
      )
    end
  end
end
