require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class MakeRebillQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',         'payment.clientId',                             true,    Validator::ID],
      ['order_desc',             'payment.description',                          true,    Validator::LONG_STRING],
      ['amount',                 'payment.amount',                               true,    Validator::AMOUNT],
      ['currency',               'payment.currency',                             true,    Validator::CURRENCY],
      ['ipaddress',              'payment.customer.ipAddress',                   true,    Validator::IP],
      ['cardrefid',              'payment.recurrentCardFrom.paynetId',           true,    Validator::ID],
      ['login',                  'queryConfig.login',                            true,    Validator::MEDIUM_STRING],
      # optional
      ['comment',                'payment.comment',                              false,   Validator::MEDIUM_STRING],
      ['cvv2',                   'payment.recurrentCardFrom.cvv2',               false,   Validator::CVV2],
      ['server_callback_url',    'queryConfig.callbackUrl',                      false,   Validator::URL]
    ]

    @@signature_definition =
    [
      'queryConfig.endPoint',
      'payment.clientId',
      'payment.amountInCents',
      'payment.recurrentCardFrom.paynetId',
      'queryConfig.signingKey'
    ]

    @@payment_status = Payment::STATUS_CAPTURE
  end
end