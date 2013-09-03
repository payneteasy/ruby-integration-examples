require 'test/unit'
require 'digest/sha1'
require 'paynet_easy_api'
require 'query/prototype/query'
require 'payment_data/payment_transaction'
require 'payment_data/payment'
require 'payment_data/query_config'
require 'transport/response'
require 'error/validation_error'
require 'error/paynet_error'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  module QueryTestPrototype
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Error

    LOGIN                     = 'test-login'
    END_POINT                 =  789
    SIGNING_KEY               = 'D5F82EC1-8575-4482-AD89-97X6X0X20X22'
    CLIENT_ID                 = 'CLIENT-112233'
    PAYNET_ID                 = 'PAYNET-112233'

    RECURRENT_CARD_FROM_ID    = '5588943'
    RECURRENT_CARD_TO_ID      = '5588978'

    def test_create_request
      raise NotImplementedError
    end

    def assert_create_request(control_code)
      payment_transaction = payment_transaction()

      request         = query.create_request payment_transaction
      request_fields  = request.request_fields

      assert_not_nil request.api_method
      assert_not_nil request.end_point
      assert_not_nil request_fields['control']
      assert_equal control_code, request_fields['control']
      assert_false payment_transaction.has_errors?

      [payment_transaction, request]
    end

    def test_create_request_with_empty_fields
      payment_transaction = PaymentTransaction.new(
      {
        'payment'       => Payment.new(
        {
          'status'        => Payment::STATUS_CAPTURE
        }),
        'query_config'  => query_config
      })

      query = query()

      assert_raise ValidationError, 'Some required fields missed or empty in Payment' do
        query.create_request payment_transaction
      end
    end

    def test_create_request_with_invalid_fields
      payment_transaction = payment_transaction()
      payment_transaction.payment.client_id   = '123456789012345678901234567890'
      payment_transaction.query_config.login  = '123456789012345678901234567890123456789012345678901234567890'

      assert_raise ValidationError, 'Some fields invalid in Payment' do
        query.create_request payment_transaction
      end
    end

    def test_process_response_error
      raise NotImplementedError
    end

    def assert_process_response_error(response)
      payment_transaction = payment_transaction()
      response_object     = Response.new response

      begin
        query.process_response payment_transaction, response_object
      rescue PaynetError => error
        assert_true payment_transaction.error?
        assert_true payment_transaction.finished?
        assert_true payment_transaction.has_errors?
        assert_equal response_object.error_message, error.message

        return [payment_transaction, response_object]
      else
        flunk 'Exception must be raised'
      end
    end

    def test_process_success_response_with_invalid_type
      response = Response.new 'type' => 'invalid'

      assert_raise ValidationError, "Response type 'invalid' does not match success response type" do
        query.process_response payment_transaction, response
      end
    end

    def test_process_success_response_with_empty_fields
      response = Response.new 'type' => success_type

      assert_raise ValidationError, 'Some required fields missed or empty in Response' do
        query.process_response payment_transaction, response
      end
    end

    def test_process_response_with_invalid_id
      response = Response.new(
      {
        'type'              => success_type,
        'paynet-order-id'   => '_',
        'merchant-order-id' => '_',
        'serial-number'     => '_',
        'card-ref-id'       => '_',
        'redirect-url'      => '_',
        'client_orderid'    => 'invalid'
      })

      assert_raise ValidationError, "Response client_id '_' does not match Payment client_id" do
        query.process_response payment_transaction, response
      end
    end

    def test_process_error_response_without_type
      response = Response.new 'status' => 'error'

      assert_raise ValidationError, 'Unknown response type' do
        query.process_response payment_transaction, response
      end
    end

    def test_process_error_response_with_invalid_id
      response = Response.new 'type' => 'error', 'client_orderid' => 'invalid'

      assert_raise ValidationError, "Response client_id 'invalid' does not match Payment client_id" do
        query.process_response payment_transaction, response
      end
    end

    protected

    # @return   [String]
    def success_type
      raise NotImplementedError, 'You must return success type for query response form this method'
    end

    # @return   [Query]
    def query
      raise NotImplementedError, 'You must implement query creation in this method'
    end

    # @return   [PaymentTransaction]
    def payment_transaction
      payment_transaction = PaymentTransaction.new({}, true)

      payment_transaction.payment       = payment()
      payment_transaction.query_config  = query_config()

      payment_transaction
    end

    # @return   [Payment]
    def payment
      raise NotImplementedError
    end

    # @return   [QueryConfig]
    def query_config
      QueryConfig.new(
      {
        'login'               =>  LOGIN,
        'end_point'           =>  END_POINT,
        'signing_key'         =>  SIGNING_KEY,
        'site_url'            => 'http://example.com',
        'gateway_url_sandbox' => 'https://example.com/sandbox_url',
        'redirect_url'        => 'https://example.com/redirect_url',
        'callback_url'        => 'https://example.com/callback_url'
      })
    end

    # Create sha1 hash sum from all method arguments
    def create_control_code(*args)
      Digest::SHA1.hexdigest(args.join(''))
    end
  end
end
