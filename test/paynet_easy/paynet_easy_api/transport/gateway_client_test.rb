require 'test/unit'
require 'paynet_easy_api'
require 'transport/request'
require 'transport/gateway_client'

module PaynetEasy::PaynetEasyApi::Transport
  class GatewayClientTest < Test::Unit::TestCase

    def setup
      @object = GatewayClient.new
    end

    def test_make_request
      request = Request.new 'login' => 'login'
      request.api_method  = 'sale'
      request.end_point   = 253
      request.gateway_url = 'https://qa.clubber.me/paynet/api/v2/'

      @object.make_request request
    end
  end
end