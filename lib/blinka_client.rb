require 'mimemagic'
require 'httparty'

class BlinkaClient
  class BlinkaConfig
    attr_reader(:branch, :commit, :host, :repository, :team_id, :team_secret, :jwt_token)
    def initialize
      @host = ENV.fetch('BLINKA_HOST', 'https://blinkblink.herokuapp.com')
      @team_id = ENV.fetch('BLINKA_TEAM_ID')
      @team_secret = ENV.fetch('BLINKA_TEAM_SECRET')
      @repository = ENV.fetch('BLINKA_REPOSITORY')
      @branch = ENV.fetch('BLINKA_BRANCH')
      @commit = `git rev-parse HEAD`.chomp
    end
  end

  class BlinkaError < StandardError; end
  include HTTParty

  def initialize
    @config = BlinkaConfig.new
    self.class.base_uri("#{@config.host}/api/v1")
  end

  def report(filepath: './blinka_results.json')
    self.authenticate
    data = JSON.parse(File.open(filepath).read)

    results =
      data
        .fetch('results', [])
        .map do |result|
          if result.key?('image')
            result['image'] =
              BlinkaClient.upload_image(filepath: result['image'])
            result
          else
            result
          end
        end

    body = {
      report: {
        repository: @config.repository,
        branch: @config.branch,
        commit: @config.commit,
        metadata: {
          total_time: data.dig('total_time'),
          nbr_tests: data.dig('nbr_tests'),
          nbr_assertions: data.dig('nbr_assertions'),
          seed: data.dig('seed')
        }.compact,
        results: results
      }
    }

    response =
      self.class.post(
        "/report",
        body: body.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@jwt_token}"
        }
      )
    case response.code
    when 200
      puts "Reported #{data.dig('nbr_tests')} tests!"
    else
      raise(BlinkaError, "Could not report, got response code #{response.code}")
    end
  end

  def self.upload_image(filepath:)
    return unless File.exist?(filepath)

    file = File.open(filepath)
    filename = File.basename(filepath)
    content_type = MimeMagic.by_magic(file).type

    presigned_post =
      BlinkaClient.presign_image(filename: filename, content_type: content_type)
    BlinkaClient.upload_to_storage(presigned_post: presigned_post, file: file)

    puts "Uploaded: #{filename}"
    BlinkaClient.to_shrine_object(
      presigned_post: presigned_post,
      file: file,
      filename: filename
    )
  end

  private

  def authenticate
    response = self.class.post(
      "/authentication",
      body: {
        token_id: @config.team_id,
        token_secret: @config.team_secret
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    case response.code
    when 200
      @jwt_token = JSON.parse(response.body).dig('auth_token')
    else
      raise(BlinkaError, 'Could not authenticate to API')
    end
  end

  def self.presign_image(filename:, content_type:)
    response =
      self.get(
        '/presign',
        body: { filename: filename, content_type: content_type }
      )

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise(BlinkaError, 'Could not presign file')
    end
  end

  def self.upload_to_storage(presigned_post:, file:)
    url = URI.parse(presigned_post.fetch('url'))
    fields = presigned_post.fetch('fields')

    body = presigned_post['fields'].merge({ 'file' => file.read })
    response = HTTParty.post(url, multipart: true, body: body)

    case response.code
    when 204
      true
    else
      raise(BlinkaError, 'Could not upload file to storage')
    end
  end

  def self.to_shrine_object(presigned_post:, file:, filename:)
    storage, idx = presigned_post.dig('fields', 'key').split('/')
    {
      "id": idx,
      "storage": storage,
      "metadata": {
        "size": file.size,
        "filename": filename,
        "mime_type": presigned_post.dig('fields', 'Content-Type')
      }
    }
  end
end
