require_relative './prototype/payment_query_test'
require 'query/return_query'

module PaynetEasy::PaynetEasyApi::Query
  class ReturnQueryTest < Prototype::PaymentQueryTest
    def initialize(test_name)
      super test_name
      @payment_status = Payment::STATUS_RETURN
      @api_method     = 'return'
    end

    def setup
      @object = ReturnQuery.new @api_method
    end

    def test_create_request
      [
        create_control_code(
           LOGIN,
           CLIENT_ID,
           PAYNET_ID,
           9910,
          'EUR',
           SIGNING_KEY
        )
      ].each do |control_code|
        assert_create_request control_code
      end
    end

    def test_create_request_with_finished_transaction
      payment_transaction = payment_transaction()
      payment_transaction.payment.status = Payment::STATUS_RETURN

      assert_raise ValidationError, 'Payment must be paid up to return funds' do
        @object.create_request payment_transaction
      end
    end

    protected

    # @return   [Payment]
    def payment
      Payment.new(
      {
        'client_id'             =>  CLIENT_ID,
        'paynet_id'             =>  PAYNET_ID,
        'amount'                =>  99.1,
        'currency'              => 'EUR',
        'comment'               => 'cancel payment',
        'status'                =>  Payment::STATUS_CAPTURE
      })
    end
  end
end
