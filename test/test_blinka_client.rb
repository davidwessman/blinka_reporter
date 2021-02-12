require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'

require 'blinka_client'

class BlinkaClientTest < Minitest::Test
  def setup
    # We must allow webmock to stay enabled, even if we need to disable it in the client.
    ENV['BLINKA_ALLOW_WEBMOCK_DISABLE'] = 'false'
    WebMock.disable_net_connect!
  end

  def teardown
    ENV['BLINKA_ALLOW_WEBMOCK_DISABLE'] = 'true'
  end

  def test_report_class_method
    stub_client
    BlinkaClient.report(filepath: 'test/example_results.json')
  end

  def stub_client
    WebMock
      .stub_request(
        :post,
        "#{BlinkaClient::DEFAULT_HOST}/api/v1/authentication"
      )
      .to_return(body: { auth_token: 'auth-token' }.to_json)
    WebMock.stub_request(:post, "#{BlinkaClient::DEFAULT_HOST}/api/v1/report")
  end
end
