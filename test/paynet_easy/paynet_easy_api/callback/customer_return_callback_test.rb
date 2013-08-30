require_relative './callback_test_prototype'
require 'callback/customer_return_callback'

module PaynetEasy::PaynetEasyApi::Callback
  class CustomerReturnCallbackTest < Test::Unit::TestCase
    include CallbackTestPrototype

    def test_process_callback_approved
      [
        {
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

    def test_process_callback_declined
      [
        {
          'status'            => 'declined',
          'amount'            =>  0.99,
          'orderid'           =>  PAYNET_ID,
          'merchant_order'    =>  CLIENT_ID,
          'client_orderid'    =>  CLIENT_ID,
        },
        {
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

    def test_process_callback_with_not_processing_transaction
      payment_transaction = payment_transaction()
      payment_transaction.status = PaymentTransaction::STATUS_APPROVED

      callback_response = CallbackResponse.new(
      [
        'status'            => 'processing',
        'amount'            =>  0.99,
        'orderid'           =>  PAYNET_ID,
        'merchant_order'    =>  CLIENT_ID,
        'client_orderid'    =>  CLIENT_ID,
      ])

      sign_callback callback_response

      assert_raise ValidationError, 'Only processing payment transaction can be processed' do
        callback_processor.process_callback payment_transaction, callback_response
      end
    end

    protected

    alias :callback_test_prototype_payment_transaction :payment_transaction

    # @return   [PaymentTransaction]
    def payment_transaction
      payment_transaction = callback_test_prototype_payment_transaction
      payment_transaction.status = PaymentTransaction::STATUS_PROCESSING
      payment_transaction
    end

    # @return   [CustomerReturnCallback]
    def callback_processor
      CustomerReturnCallback.new 'customer_return'
    end
  end
end