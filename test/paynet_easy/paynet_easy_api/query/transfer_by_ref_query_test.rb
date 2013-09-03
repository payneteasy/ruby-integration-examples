require_relative './prototype/payment_query_test_prototype'
require 'query/transfer_by_ref_query'
require 'payment_data/recurrent_card'

module PaynetEasy::PaynetEasyApi::Query
  class TransferByRefQueryTest < Test::Unit::TestCase
    include Prototype::PaymentQueryTestPrototype

    def test_create_request
      [
        create_control_code(
          LOGIN,
          CLIENT_ID,
          RECURRENT_CARD_FROM_ID,
          RECURRENT_CARD_TO_ID,
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
        'description'           => 'This is test payment',
        'amount'                =>  99.1,
        'currency'              => 'EUR',
        'customer'              =>  Customer.new(
        {
          'ip_address'            => '127.0.0.1'
        }),
        'recurrent_card_from'   =>  RecurrentCard.new(
        {
          'paynet_id'             => RECURRENT_CARD_FROM_ID,
          'cvv2'                  => 123
        }),
        'recurrent_card_to'     =>  RecurrentCard.new(
        {
          'paynet_id'             => RECURRENT_CARD_TO_ID,
        })
      })
    end

    def payment_status
      Payment::STATUS_CAPTURE
    end

    def api_method
      'transfer-by-ref'
    end

    def query
      TransferByRefQuery.new api_method
    end
  end
end
