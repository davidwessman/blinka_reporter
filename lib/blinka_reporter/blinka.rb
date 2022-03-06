require 'httparty'
require 'blinka_reporter/error'

module BlinkaReporter
  class Blinka
    SUPPORTED_MIME_TYPES = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png'
    }

    include HTTParty

    def self.report(data:, config:)
      Blinka.new(data: data, config: config).report
    end

    def initialize(data:, config:)
      @data = data
      @config = config
      self.class.base_uri("#{@config.host}/api/v1")
    end

    def report
      if ENV.fetch('BLINKA_ALLOW_WEBMOCK_DISABLE', 'true') == 'true' &&
           defined?(WebMock) && WebMock.respond_to?(:disable!)
        WebMock.disable!
      end

      @config.validate_blinka
      self.authenticate

      results =
        @data
          .fetch(:results, [])
          .map do |result|
            if !result[:image].nil?
              result[:image] = Blinka.upload_image(filepath: result[:image])
              result
            else
              result
            end
          end

      body = {
        report: {
          repository: @config.repository,
          tag: @config.tag,
          commit: @config.commit,
          metadata: {
            total_time: @data[:total_time],
            nbr_tests: @data[:nbr_tests],
            nbr_assertions: @data[:nbr_assertions],
            seed: @data[:seed]
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
        puts "Reported #{@data[:nbr_tests]} tests of commit #{@config.commit}!"
      else
        raise(
          BlinkaReporter::Error,
          "Could not report, got response code #{response.code}"
        )
      end
    rescue => error
      raise(BlinkaReporter::Error, <<-EOS)
        BLINKA:
          Failed to create report because of #{error.class} with message:
          #{error.message}
        EOS
    ensure
      WebMock.enable! if defined?(WebMock) && WebMock.respond_to?(:enable!)
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
        raise(
          BlinkaReporter::Error,
          "Could not authenticate to API #{response.code}"
        )
      end
    end

    def self.upload_image(filepath:)
      return unless File.exist?(filepath)

      file = File.open(filepath)
      filename = File.basename(filepath)
      extension = File.extname(filepath).delete('.').to_sym
      content_type = SUPPORTED_MIME_TYPES[extension]
      return if content_type.nil?

      presigned_post =
        Blinka.presign_image(filename: filename, content_type: content_type)
      Blinka.upload_to_storage(presigned_post: presigned_post, file: file)

      puts "Uploaded: #{filename}"
      Blinka.to_shrine_object(
        presigned_post: presigned_post,
        file: file,
        filename: filename
      )
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
        raise(BlinkaReporter::Error, 'Could not presign file')
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
        raise(BlinkaReporter::Error, 'Could not upload file to storage')
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
end
