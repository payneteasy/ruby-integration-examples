require_relative './prototype/payment_query_test_prototype'
require 'query/sale_form_query'
require 'payment_data/customer'
require 'payment_data/billing_address'

module PaynetEasy::PaynetEasyApi::Query
  class SaleFormQueryTest < Test::Unit::TestCase
    include Prototype::PaymentQueryTestPrototype

    def test_create_request
      [
        create_control_code(
           END_POINT,
           CLIENT_ID,
           9910,
          'vass.pupkin@example.com',
           SIGNING_KEY
        )
      ].each do |control_code|
        assert_create_request control_code
      end
    end

    def test_process_response_processing
      [
        {
          'type'              =>  success_type,
          'status'            => 'processing',
          'merchant-order-id' =>  CLIENT_ID,
          'paynet-order-id'   =>  PAYNET_ID,
          'serial-number'     => '_',
          'redirect-url'      => 'http://redirect-url.com'
        }
      ].each do |response|
        assert_process_response_processing response
      end
    end

    alias :payment_query_test_assert_process_response_processing assert_process_response_processing

    def assert_process_response_processing(response)
      payment_transaction, response_object = payment_query_test_assert_process_response_processing response

      assert_true response_object.redirect_needed?

      [payment_transaction, response_object]
    end

    protected

    def payment
      Payment.new(
      {
        'client_id'             => CLIENT_ID,
        'paynet_id'             => PAYNET_ID,
        'description'           => 'This is test payment',
        'amount'                =>  99.1,
        'currency'              => 'USD',
        'customer'              => Customer.new(
        {
          'first_name'            => 'Vasya',
          'last_name'             => 'Pupkin',
          'email'                 => 'vass.pupkin@example.com',
          'ip_address'            => '127.0.0.1',
          'birthday'              => '112681'
        }),
        'billing_address'       => BillingAddress.new(
        {
          'country'               => 'US',
          'state'                 => 'TX',
          'city'                  => 'Houston',
          'first_line'            => '2704 Colonial Drive',
          'zip_code'              => '1235',
          'phone'                 => '660-485-6353',
          'cell_phone'            => '660-485-6353'
        })
      })
    end

    def payment_status
      Payment::STATUS_CAPTURE
    end

    def api_method
      'sale-form'
    end

    def query
      SaleFormQuery.new api_method
    end

    def success_type
      'async-form-response'
    end
  end
end
