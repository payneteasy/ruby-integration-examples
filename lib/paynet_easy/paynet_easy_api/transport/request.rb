require 'contracts'

module PaynetEasy::PaynetEasyApi::Transport
  class Request
    include Contracts

    attr_accessor :api_method
    attr_accessor :end_point
    attr_accessor :gateway_url
    attr_reader :request_fields

    def initialize(request_fields = {})
      @request_fields = request_fields
    end

    Contract String => Any
    def gateway_url=(gateway_url)
      @gateway_url = gateway_url.chomp '/'
    end

    Contract String => Any
    def signature=(signature)
      request_fields['control'] = signature
    end
  end
end