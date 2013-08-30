require_relative './callback_test_prototype'
require 'callback/paynet_easy_callback'

module PaynetEasy::PaynetEasyApi::Callback
  class PaynetEasyCallbackTest < Test::Unit::TestCase
    include CallbackTestPrototype

    def test_process_callback_approved
      [
        {
          'type'              => 'sale',
          'status'            => 'approved',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
        }
      ].each do |callback|
        assert_process_callback_approved callback
      end
    end

    alias :callback_test_prototype_assert_process_callback_approved :assert_process_callback_approved

    def assert_process_callback_approved(callback)
      payment_transaction, callback_response = callback_test_prototype_assert_process_callback_approved callback

      assert_equal PaymentTransaction::PROCESSOR_CALLBACK, payment_transaction.processor_type
      assert_equal callback_response.type, payment_transaction.processor_name

      [payment_transaction, callback_response]
    end

    def test_process_callback_declined
      [
        {
          'type'              => 'sale',
          'status'            => 'declined',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
        },
        {
          'type'              => 'sale',
          'status'            => 'filtered',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
        }
      ].each do |callback|
        assert_process_callback_declined callback
      end
    end

    def test_process_callback_error
      [
        {
          'type'              => 'sale',
          'status'            => 'error',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
          'error_message'     => 'test type error message',
          'error_code'        =>  5
        }
      ].each do |callback|
        assert_process_callback_error callback
      end
    end

    def test_process_callback_with_not_new_transaction
      payment_transaction = payment_transaction()
      payment_transaction.status = PaymentTransaction::STATUS_PROCESSING

      callback_response = CallbackResponse.new(
      [
          'status'            => 'approved',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
      ])

      sign_callback callback_response

      assert_raise ValidationError, 'Only new payment transaction can be processed' do
        callback_processor.process_callback payment_transaction, callback_response
      end
    end

    protected

    # @return   [PaynetEasyCallback]
    def callback_processor
      PaynetEasyCallback.new 'sale'
    end
  end
end
