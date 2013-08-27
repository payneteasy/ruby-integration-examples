require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class TransferByRefQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',             'payment.client_id',                            true,    Validator::ID],
      ['amount',                     'payment.amount',                               true,    Validator::AMOUNT],
      ['currency',                   'payment.currency',                             true,    Validator::CURRENCY],
      ['ipaddress',                  'payment.customer.ip_address',                  true,    Validator::IP],
      ['destination-card-ref-id',    'payment.recurrent_card_to.paynet_id',          true,    Validator::ID],
      ['login',                      'query_config.login',                           true,
       Validator::MEDIUM_STRING],
      # optional
      ['order_desc',                 'payment.description',                          false,   Validator::LONG_STRING],
      ['source-card-ref-id',         'payment.recurrent_card_from.paynet_id',        false,   Validator::ID],
      ['cvv2',                       'payment.recurrent_card_from.cvv2',             false,   Validator::CVV2],
      ['redirect_url',               'query_config.redirect_url',                    false,   Validator::URL],
      ['server_callback_url',        'query_config.callback_url',                    false,   Validator::URL]
    ]

    @@signature_definition =
    [
      'query_config.login',
      'payment.client_id',
      'payment.recurrent_card_from.paynet_id',
      'payment.recurrent_card_to.paynet_id',
      'payment.amount_in_cents',
      'payment.currency',
      'query_config.signing_key'
    ]

    @@payment_status = Payment::STATUS_CAPTURE
  end
end