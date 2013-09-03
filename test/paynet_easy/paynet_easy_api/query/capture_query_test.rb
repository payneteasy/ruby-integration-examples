require_relative './prototype/payment_query_test_prototype'
require 'query/capture_query'
require 'payment_data/payment'

module PaynetEasy::PaynetEasyApi::Query
  class CaptureQueryTest < Test::Unit::TestCase
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

    protected

    def payment
      Payment.new(
      {
        'client_id'             =>  CLIENT_ID,
        'paynet_id'             =>  PAYNET_ID,
        'amount'                =>  99.1,
        'currency'              => 'EUR'
      })
    end

    def query
      CaptureQuery.new api_method
    end

    def payment_status
      Payment::STATUS_CAPTURE
    end

    def api_method
      'capture'
    end
  end
end