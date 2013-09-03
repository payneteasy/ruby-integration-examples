require_relative './prototype/payment_query_test_prototype'
require 'query/make_rebill_query'
require 'payment_data/customer'
require 'payment_data/recurrent_card'

module PaynetEasy::PaynetEasyApi::Query
  class MakeRebillQueryTest < Test::Unit::TestCase
    include Prototype::PaymentQueryTestPrototype

    def test_create_request
      [
        create_control_code(
          END_POINT,
          CLIENT_ID,
          '99',                   # amount
          RECURRENT_CARD_FROM_ID,
          SIGNING_KEY
        )
      ].each do |control_code|
        assert_create_request control_code
      end
    end

    protected

    # @return   [Payment]
    def payment
      Payment.new(
      {
        'client_id'             =>  CLIENT_ID,
        'paynet_id'             =>  PAYNET_ID,
        'description'           => 'This is test payment',
        'amount'                =>  0.99,
        'currency'              => 'USD',
        'customer'              =>  Customer.new(
        {
          'ip_address'            => '127.0.0.1',
        }),
        'recurrent_card_from'   =>  RecurrentCard.new(
        {
          'paynet_id'             => RECURRENT_CARD_FROM_ID,
          'cvv2'                  => 123
        })
      })
    end

    def payment_status
      Payment::STATUS_CAPTURE
    end

    def api_method
      'make-rebill'
    end

    def query
      MakeRebillQuery.new api_method
    end
  end
end
