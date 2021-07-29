require 'httparty'

class BlinkaClient
  DEFAULT_HOST = 'https://www.blinka.app'.freeze
  SUPPORTED_MIME_TYPES = {
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png'
  }

  include HTTParty

  class BlinkaConfig
    attr_reader(:host, :repository, :team_id, :team_secret, :jwt_token)

    def initialize
      @host = ENV.fetch('BLINKA_HOST', DEFAULT_HOST)
      @team_id = ENV.fetch('BLINKA_TEAM_ID', nil)
      @team_secret = ENV.fetch('BLINKA_TEAM_SECRET', nil)
      @repository = ENV.fetch('BLINKA_REPOSITORY', nil)

      if @team_id.nil? || @team_secret.nil? || @repository.nil?
        raise(BlinkaError, <<~EOS)
          Missing configuration, make sure to set required environment variables:
          - BLINKA_TEAM_ID
          - BLINKA_TEAM_SECRET
          - BLINKA_REPOSITORY
          EOS
      end
    end
  end

  class BlinkaError < StandardError; end

  def initialize
    @config = BlinkaConfig.new
    self.class.base_uri("#{@config.host}/api/v1")
  end

  def report(filepath: './blinka_results.json')
    unless File.exist?(filepath)
      raise(
        BlinkaError,
        'Could not find blinka_results.json, did tests run with environment variable BLINKA_JSON=true set?'
      )
    end

    if ENV.fetch('BLINKA_ALLOW_WEBMOCK_DISABLE', 'true') == 'true' &&
         defined?(WebMock) && WebMock.respond_to?(:disable!)
      WebMock.disable!
    end

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
        tag: data['tag'],
        commit: data['commit'],
        metadata: {
          total_time: data['total_time'],
          nbr_tests: data['nbr_tests'],
          nbr_assertions: data['nbr_assertions'],
          seed: data['seed']
        }.compact,
        results: results
      }
    }

    response =
      self.class.post(
        '/report',
        body: body.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@jwt_token}"
        }
      )
    case response.code
    when 200
      puts "Reported #{data['nbr_tests']} tests of commit #{data['commit']}!"
    else
      raise(BlinkaError, "Could not report, got response code #{response.code}")
    end
  rescue => error
    raise(BlinkaError, <<-EOS)
      BLINKA:
        Failed to create report because of #{error.class} with message:
        #{error.message}
      EOS
  ensure
    WebMock.enable! if defined?(WebMock) && WebMock.respond_to?(:enable!)
  end

  def self.report(filepath: './blinka_results.json')
    client = BlinkaClient.new
    client.report(filepath: filepath)
  end

  def self.upload_image(filepath:)
    return unless File.exist?(filepath)

    file = File.open(filepath)
    filename = File.basename(filepath)
    extension = File.extname(filepath).delete('.').to_sym
    content_type = SUPPORTED_MIME_TYPES[extension]
    return if content_type.nil?

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

  def authenticate
    response =
      self.class.post(
        '/authentication',
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
