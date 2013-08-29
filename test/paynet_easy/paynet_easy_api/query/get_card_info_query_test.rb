require_relative './prototype/sync_query_test'
require 'query/get_card_info_query'
require 'payment_data/recurrent_card'

module PaynetEasy::PaynetEasyApi::Query
  class GetCardInfoQueryTest < Test::Unit::TestCase
    include Prototype::SyncQueryTest

    def test_create_request
      [
        create_control_code(
          LOGIN,
          RECURRENT_CARD_FROM_ID,
          SIGNING_KEY
        )
      ].each do |control_code|
        assert_create_request control_code
      end
    end

    def test_process_response_approved
      [
        {
          'type'              =>  success_type,
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_',
          'card-printed-name' => 'Vasya Pupkin',
          'expire-month'      => '12',
          'expire-year'       => '14',
          'bin'               => '4485',
          'last-four-digits'  => '9130'
        }
      ].each do |response|
        assert_process_response_approved response
      end
    end

    def assert_process_response_approved(response)
      payment_transaction = payment_transaction()
      recurrent_card      = payment_transaction.payment.recurrent_card_from
      response_object     = Response.new response

      query.process_response payment_transaction, response_object

      assert_equal response_object['card-printed-name'],  recurrent_card.card_printed_name
      assert_equal response_object['expire-year'],        recurrent_card.expire_year
      assert_equal response_object['expire-month'],       recurrent_card.expire_month
      assert_equal response_object['bin'],                recurrent_card.bin
      assert_equal response_object['last-four-digits'],   recurrent_card.last_four_digits

      [payment_transaction, response]
    end

    def test_process_error_response_with_invalid_id
      response = Response.new(
      {
        'type'              => 'error',
        'client_orderid'    => 'invalid',
        'card-printed-name' => 'Vasya Pupkin',
        'expire-month'      => '12',
        'expire-year'       => '14',
        'bin'               => '4485',
        'last-four-digits'  => '9130'
      })

      assert_raise ValidationError, "Response client_id 'invalid' does not match Payment client_id" do
        query.process_response payment_transaction, response
      end
    end

    def test_process_success_response_with_invalid_id
      response = Response.new(
      {
        'type'              => success_type,
        'paynet-order-id'   => '_',
        'merchant-order-id' => '_',
        'serial-number'     => '_',
        'card-ref-id'       => '_',
        'redirect-url'      => '_',
        'client_orderid'    => 'invalid',
        'card-printed-name' => 'Vasya Pupkin',
        'expire-month'      => '12',
        'expire-year'       => '14',
        'bin'               => '4485',
        'last-four-digits'  => '9130'
      })

      assert_raise ValidationError, "Response client_id '_' does not match Payment client_id" do
        query.process_response payment_transaction, response
      end
    end

    protected

    def payment
      Payment.new(
      {
        'client_id'             => CLIENT_ID,
        'paynet_id'             => PAYNET_ID,
        'recurrent_card_from'   => RecurrentCard.new(
        {
          'paynet_id'             => RECURRENT_CARD_FROM_ID
        })
      })
    end

    def success_type
      'get-card-info-response'
    end

    def query
      GetCardInfoQuery.new '_'
    end
  end
end
