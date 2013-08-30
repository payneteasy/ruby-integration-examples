require 'test/unit'
require 'digest/sha1'
require 'paynet_easy_api'
require 'callback/callback_prototype'
require 'payment_data/payment_transaction'
require 'payment_data/payment'
require 'payment_data/query_config'
require 'transport/callback_response'
require 'error/validation_error'
require 'error/paynet_error'

module PaynetEasy::PaynetEasyApi::Callback
  module CallbackTestPrototype
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Error

    SIGNING_KEY   = 'D5F82EC1-8575-4482-AD89-97X6X0X20X22'
    CLIENT_ID     = 'CLIENT-112233'
    PAYNET_ID     = 'PAYNET-112233'

    def test_process_callback_approved
      raise NotImplementedError
    end

    def assert_process_callback_approved(callback)
      payment_transaction = payment_transaction()
      callback_response   = CallbackResponse.new callback
      sign_callback callback_response

      callback_processor.process_callback payment_transaction, callback_response

      assert_true payment_transaction.approved?
      assert_true payment_transaction.finished?
      assert_false payment_transaction.has_errors?

      [payment_transaction, callback_response]
    end

    def test_process_callback_declined
      raise NotImplementedError
    end

    def assert_process_callback_declined(callback)
      payment_transaction = payment_transaction()
      callback_response   = CallbackResponse.new callback
      sign_callback callback_response

      callback_processor.process_callback payment_transaction, callback_response

      assert_true payment_transaction.declined?
      assert_true payment_transaction.finished?
      assert_true payment_transaction.has_errors?
    end

    def test_process_callback_error
      raise NotImplementedError
    end

    def assert_process_callback_error(callback)
      payment_transaction = payment_transaction()
      callback_response   = CallbackResponse.new callback
      sign_callback callback_response

      begin
        callback_processor.process_callback payment_transaction, callback_response
      rescue PaynetError => error
        assert_true payment_transaction.error?
        assert_true payment_transaction.finished?
        assert_true payment_transaction.has_errors?
        assert_equal callback_response.error_message, error.message

        [payment_transaction, callback_response]
      else
        flunk 'Exception must be raised'
      end
    end

    def test_process_callback_with_empty_control
      assert_raise ValidationError, "Actual control code '' does not equal expected" do
        callback_processor.process_callback payment_transaction, Response.new
      end
    end

    def test_process_callback_with_empty_fields
      callback_response = CallbackResponse.new(
      [
        'status'            => 'approved',
        'orderid'           => '_',
        'client_orderid'    => '_'
      ])

      sign_callback callback_response

      assert_raise ValidationError, 'Some required fields missed or empty in CallbackResponse' do
        callback_processor.process_callback payment_transaction, callback_response
      end
    end

    def test_process_callback_with_unequal_fields
      callback_response = CallbackResponse.new(
      [
        'status'            => 'approved',
        'orderid'           => 'unequal',
        'merchant_order'    => 'unequal',
        'client_orderid'    => 'unequal'
      ])

      sign_callback callback_response

      assert_raise ValidationError, 'Some fields from CallbackResponse unequal properties from Payment' do
        callback_processor.process_callback payment_transaction, callback_response
      end
    end

    def test_process_callback_with_invalid_status
      callback_response = CallbackResponse.new(
      [
        'status'            => 'processing',
        'amount'            =>  0.99,
        'orderid'           =>  PAYNET_ID,
        'merchant_order'    =>  CLIENT_ID,
        'client_orderid'    =>  CLIENT_ID,
      ])

      sign_callback callback_response

      assert_raise ValidationError, "Invalid callback status: 'processing'" do
        callback_processor.process_callback payment_transaction, callback_response
      end
    end

    protected

    # @return   [CallbackPrototype]
    def callback_processor
      raise NotImplementedError
    end

    # @return   [PaymentTransaction]
    def payment_transaction
      PaymentTransaction.new(
      {
        'payment'           =>    Payment.new(
        {
          'client_id'         =>  CLIENT_ID,
          'paynet_id'         =>  PAYNET_ID,
          'amount'            =>  0.99,
          'currency'          => 'USD',
        }),
        'query_config'      =>    QueryConfig.new(
        {
          'signing_key'       =>  SIGNING_KEY
        })
      })
    end

    # @param    callback_response   [CallbackResponse]
    def sign_callback(callback_response)
      callback_response['control'] = Digest::SHA1.hexdigest(
        callback_response.status +
        callback_response.payment_paynet_id.to_s +
        callback_response.payment_client_id.to_s +
        SIGNING_KEY
      )
    end
  end
end
