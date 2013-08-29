require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class SaleQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @request_fields_definition =
    [
      # mandatory
      ['client_orderid',         'payment.client_id',                       true,   Validator::ID],
      ['order_desc',             'payment.description',                     true,   Validator::LONG_STRING],
      ['amount',                 'payment.amount',                          true,   Validator::AMOUNT],
      ['currency',               'payment.currency',                        true,   Validator::CURRENCY],
      ['address1',               'payment.billing_address.first_line',      true,   Validator::MEDIUM_STRING],
      ['city',                   'payment.billing_address.city',            true,   Validator::MEDIUM_STRING],
      ['zip_code',               'payment.billing_address.zip_code',        true,   Validator::ZIP_CODE],
      ['country',                'payment.billing_address.country',         true,   Validator::COUNTRY],
      ['phone',                  'payment.billing_address.phone',           true,   Validator::PHONE],
      ['ipaddress',              'payment.customer.ip_address',             true,   Validator::IP],
      ['email',                  'payment.customer.email',                  true,   Validator::EMAIL],
      ['card_printed_name',      'payment.credit_card.card_printed_name',   true,   Validator::LONG_STRING],
      ['credit_card_number',     'payment.credit_card.credit_card_number',  true,   Validator::CREDIT_CARD_NUMBER],
      ['expire_month',           'payment.credit_card.expire_month',        true,   Validator::MONTH],
      ['expire_year',            'payment.credit_card.expire_year',         true,   Validator::YEAR],
      ['cvv2',                   'payment.credit_card.cvv2',                true,   Validator::CVV2],
      ['redirect_url',           'query_config.redirect_url',               true,   Validator::URL],
      # optional
      ['first_name',             'payment.customer.first_name',             false,  Validator::MEDIUM_STRING],
      ['last_name',              'payment.customer.last_name',              false,  Validator::MEDIUM_STRING],
      ['ssn',                    'payment.customer.ssn',                    false,  Validator::SSN],
      ['birthday',               'payment.customer.birthday',               false,  Validator::DATE],
      ['state',                  'payment.billing_address.state',           false,  Validator::COUNTRY],
      ['cell_phone',             'payment.billing_address.cell_phone',      false,  Validator::PHONE],
      ['destination',            'payment.destination',                     false,  Validator::LONG_STRING],
      ['site_url',               'query_config.site_url',                   false,  Validator::URL],
      ['server_callback_url',    'query_config.callback_url',               false,  Validator::URL]
    ]

    @signature_definition =
    [
      'query_config.end_point',
      'payment.client_id',
      'payment.amount_in_cents',
      'payment.customer.email',
      'query_config.signing_key'
    ]

    @payment_status = Payment::STATUS_CAPTURE
  end
end