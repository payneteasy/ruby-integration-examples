require_relative './prototype/sync_query_test_prototype'
require 'query/status_query'

module PaynetEasy::PaynetEasyApi::Query
  class StatusQueryTest < Test::Unit::TestCase
    include Prototype::SyncQueryTestPrototype

    def test_create_request
      [
        create_control_code(
          LOGIN,
          CLIENT_ID,
          PAYNET_ID,
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
          'status'            => 'approved',
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_'
        }
      ].each do |response|
        assert_process_response_approved response
      end
    end

    def test_process_response_processing
      [
        {
          'type'              =>  success_type,
          'status'            => 'processing',
          'html'              => '<html></html>',
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_'
        }
      ].each do |response|
        assert_process_response_processing response
      end
    end

    def assert_process_response_processing(response)
      payment_transaction = payment_transaction()
      response_object = Response.new response

      query.process_response payment_transaction, response_object

      assert_true payment_transaction.processing?
      assert_false payment_transaction.finished?
      assert_false payment_transaction.has_errors?

      assert_true response_object.show_html_needed?
    end

    protected

    def payment
      Payment.new(
      {
        'client_id'             => CLIENT_ID,
        'paynet_id'             => PAYNET_ID
      })
    end

    def success_type
      'status-response'
    end

    def query
      StatusQuery.new '_'
    end
  end
end
