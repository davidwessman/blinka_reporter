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
    @config = BlinkaReporter::Config.new
    stub_client
    BlinkaReporter::Config.any_instance.expects(:validate_blinka).returns(true)
  end

  def teardown
    ENV['BLINKA_ALLOW_WEBMOCK_DISABLE'] = 'true'
  end

  def test_report_class_method_json
    BlinkaReporter::Client.report(
      path: 'test/example_results.json',
      tap: true,
      blinka: true
    )
  end

  def test_report_class_method_json2
    BlinkaReporter::Client.report(
      path: 'test/blinka_results.json',
      tap: true,
      blinka: true
    )
  end

  def test_report_class_method_xml
    BlinkaReporter::Client.report(
      path: 'test/rspec.xml',
      blinka: true,
      tap: true
    )
  end

  def stub_client
    WebMock
      .stub_request(:post, "#{@config.host}/api/v1/authentication")
      .to_return(body: { auth_token: 'auth-token' }.to_json)
    WebMock
      .stub_request(:get, "#{@config.host}/api/v1/presign")
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
    WebMock.stub_request(:post, "#{@config.host}/api/v1/report")
  end
end
