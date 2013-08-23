require 'contracts'
require 'net/http'
require 'uri'
require 'cgi'

require 'transport/request'
require 'transport/response'
require 'util/validator'

require 'error/validation_error'
require 'error/request_error'

module PaynetEasy::PaynetEasyApi::Transport
  class GatewayClient
    include Contracts
    include Net
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Error

    Contract Request => Response
    # Make request to the PaynetEasy gateway
    #
    # @param    request   [Request]     Request data
    #
    # @return             [Response]    Response data
    def make_request(request)
      validate_request request
      response = send_request request
      parse_response response
    end

    protected

    Contract Request => HTTPOK
    # Executes request
    #
    # @param    request   [Request]         Request to execute
    #
    # @return             [HTTPResponse]    PaynetEasy response as HTTPResponse
    def send_request(request)
      begin
        uri = URI "#{request.gateway_url}/#{request.api_method}/#{request.end_point}"

        response = HTTP.start uri.hostname, uri.port, :use_ssl => uri.scheme == 'https' do |http|
          post = HTTP::Post.new uri.request_uri
          post.set_form_data request.request_fields
          http.request post
        end
      rescue Exception => e
        raise RequestError, "Error occurred. #{e.message}"
      end

      unless HTTPOK === response
        raise RequestError, "Error occurred. HTTP code: '#{response.code}'. Server message: '#{response.message}'"
      end

      response
    end

    Contract HTTPOK => Response
    # Parse PaynetEasy response from string to Response object
    #
    # @param    response    [HTTPResponse]    PaynetEasy response as HTTPResponse
    #
    # @return               [Response]        PaynetEasy response as Response
    def parse_response(response)
      unless response.body
        raise ResponseError, 'PaynetEasy response is empty'
      end

      # Change hash format from {'key' => ['value']} to {'key' => 'value'} in map block
      response_fields = Hash[CGI.parse(response.body).map {|key, value| [key, value.first]}]

      Response.new response_fields
    end

    Contract Request => Any
    # Validates Request
    #
    # @param    request   [Request]           Request for validation
    def validate_request(request)
      validation_errors = []

      validation_errors << 'Request api method is empty'  unless request.api_method
      validation_errors << 'Request end point is empty'   unless request.end_point
      validation_errors << 'Request data is empty'        unless request.request_fields.any?

      unless Validator.validate_by_rule request.gateway_url, Validator::URL, false
        validation_errors << 'Gateway url does not valid in Request'
      end

      if validation_errors.any?
        raise ValidationError, "Some Request fields are invalid:\n#{validation_errors.join(";\n")}"
      end
    end
  end
end