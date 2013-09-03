require_relative './prototype/payment_query_test_prototype'
require 'query/return_query'

module PaynetEasy::PaynetEasyApi::Query
  class ReturnQueryTest < Test::Unit::TestCase
    include Prototype::PaymentQueryTestPrototype

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
        query.create_request payment_transaction
      end
    end

    protected

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

    def payment_status
      Payment::STATUS_RETURN
    end

    def api_method
      'return'
    end

    def query
      ReturnQuery.new api_method
    end
  end
end
