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
      ['client_orderid',             'payment.clientId',                             true,    Validator::ID],
      ['amount',                     'payment.amount',                               true,    Validator::AMOUNT],
      ['currency',                   'payment.currency',                             true,    Validator::CURRENCY],
      ['ipaddress',                  'payment.customer.ipAddress',                   true,    Validator::IP],
      ['destination-card-ref-id',    'payment.recurrentCardTo.paynetId',             true,    Validator::ID],
      ['login',                      'queryConfig.login',                            true,    Validator::MEDIUM_STRING],
      # optional
      ['order_desc',                 'payment.description',                          false,   Validator::LONG_STRING],
      ['source-card-ref-id',         'payment.recurrentCardFrom.paynetId',           false,   Validator::ID],
      ['cvv2',                       'payment.recurrentCardFrom.cvv2',               false,   Validator::CVV2],
      ['redirect_url',               'queryConfig.redirectUrl',                      false,   Validator::URL],
      ['server_callback_url',        'queryConfig.callbackUrl',                      false,   Validator::URL]
    ]

    @@signature_definition =
    [
      'queryConfig.login',
      'payment.clientId',
      'payment.recurrentCardFrom.paynetId',
      'payment.recurrentCardTo.paynetId',
      'payment.amountInCents',
      'payment.currency',
      'queryConfig.signingKey'
    ]

    @@payment_status = Payment::STATUS_CAPTURE
  end
end