require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'

require 'blinka_reporter/client'
require 'blinka_reporter/config'

class BlinkaReporterMinitestAdapterTest < Minitest::Test
  S3_URL = 'https://blinka.s3storage.com'
  def setup
    # We must allow webmock to stay enabled, even if we need to disable it in the client.
    ENV['BLINKA_ALLOW_WEBMOCK_DISABLE'] = 'false'
    WebMock.disable_net_connect!
    stub_client
    BlinkaReporter::Config.any_instance.expects(:validate_blinka).returns(true)
  end

  def teardown
    ENV['BLINKA_ALLOW_WEBMOCK_DISABLE'] = 'true'
  end

  def test_report_class_method_json
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/example_results.json')
    client.report(data: data, config: config, tap: true, blinka: true)
  end

  def test_report_class_method_json2
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/blinka_results.json')
    client.report(data: data, config: config, tap: true, blinka: true)
  end

  def test_report_class_method_xml
    client = BlinkaReporter::Client.new
    data = client.parse(paths: 'test/rspec.xml')
    client.report(data: data, config: config, tap: true, blinka: true)
  end

  def test_combining_results
    client = BlinkaReporter::Client.new
    data = client.parse(paths: %w[test/rspec.xml test/blinka_results.json])
    client.report(data: data, config: config, tap: true, blinka: true)
  end

  def stub_client
    WebMock
      .stub_request(
        :post,
        "#{BlinkaReporter::Config::DEFAULT_HOST}/api/v1/authentication"
      )
      .to_return(body: { auth_token: 'auth-token' }.to_json)
    WebMock
      .stub_request(
        :get,
        "#{BlinkaReporter::Config::DEFAULT_HOST}/api/v1/presign"
      )
      .to_return(
        body: {
          fields: {
            :key => 'cache/123912y39bsakdiashd1.png',
            'Content-Disposition' =>
              "inline; filename=\"image.png\"; filename*=UTF-8''image.png",
            'Content-Type' => 'image/png',
            :policy => 'asdiasdai',
            :"x-amz-credential" => 'blabla',
            :"x-amz-algorithm" => 'AWS4-HMAC-SHA256',
            :"x-amz-date" => '20210325T074232Z',
            :"x-amz-signature" => 'baosdoahsdoas'
          },
          headers: {},
          method: :post,
          url: S3_URL
        }.to_json
      )
    WebMock.stub_request(:post, S3_URL).to_return(status: 204)
    WebMock.stub_request(
      :post,
      "#{BlinkaReporter::Config::DEFAULT_HOST}/api/v1/report"
    )
  end

  def config
    BlinkaReporter::Config.new(
      tag: '',
      commit: SecureRandom.hex(16),
      team_id: 'c82797eeb897ef195bfc',
      team_secret: 'bb47b4b25a365c86108fa1b667b9df9b',
      repository: 'davidwessman/blinka'
    )
  end
end
