require_relative './prototype/payment_query_test_prototype'
require 'query/sale_query'
require 'payment_data/customer'
require 'payment_data/billing_address'
require 'payment_data/credit_card'

module PaynetEasy::PaynetEasyApi::Query
  class SaleQueryTest < Test::Unit::TestCase
    include Prototype::PaymentQueryTestPrototype

    def test_create_request
      [
        create_control_code(
          END_POINT,
          CLIENT_ID,
          '99',                       # amount
          'vass.pupkin@example.com',
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
        'amount'                =>  0.99,
        'currency'              => 'USD',
        'destination'           => 'destination',
        'customer'              =>  Customer.new(
        {
          'first_name'            => 'Vasya',
          'last_name'             => 'Pupkin',
          'email'                 => 'vass.pupkin@example.com',
          'ip_address'            => '127.0.0.1',
          'birthday'              => '112681',
          'ssn'                   => '8397'
        }),
        'billing_address'       =>  BillingAddress.new(
        {
          'country'               => 'US',
          'state'                 => 'TX',
          'city'                  => 'Houston',
          'first_line'            => '2704 Colonial Drive',
          'zip_code'              => '1235',
          'phone'                 => '660-485-6353',
          'cell_phone'            => '660-485-6353'
        }),
        'credit_card'           =>  CreditCard.new(
        {
          'card_printed_name'     => 'Vasya Pupkin',
          'credit_card_number'    => '4485 9408 2237 9130',
          'expire_month'          => '12',
          'expire_year'           => '14',
          'cvv2'                  => '084'
        })
      })
    end

    def payment_status
      Payment::STATUS_CAPTURE
    end

    def api_method
      'sale'
    end

    def query
      SaleQuery.new api_method
    end
  end
end
