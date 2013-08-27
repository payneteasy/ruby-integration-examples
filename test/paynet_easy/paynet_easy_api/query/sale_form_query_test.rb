require_relative './prototype/payment_query_test'
require 'query/sale_form_query'
require 'payment_data/customer'
require 'payment_data/billing_address'

module PaynetEasy::PaynetEasyApi::Query
  class SaleFormQueryTest < Prototype::PaymentQueryTest
    def initialize(test_name)
      super test_name
      @payment_status = Payment::STATUS_CAPTURE
      @api_method     = 'sale-form'
    end

    def setup
      @object = SaleFormQuery.new @api_method
    end

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
          'type'              =>  @success_type,
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

    def assert_process_response_processing(response)
      payment_transaction, response_object = super response

      assert_true response_object.redirect_needed?

      [payment_transaction, response_object]
    end

    protected

    # @return   [Payment]
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
  end
end
