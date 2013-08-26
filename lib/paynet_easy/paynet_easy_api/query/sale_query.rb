require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class SaleQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',         'payment.clientId',                     true,   Validator::ID],
      ['order_desc',             'payment.description',                  true,   Validator::LONG_STRING],
      ['amount',                 'payment.amount',                       true,   Validator::AMOUNT],
      ['currency',               'payment.currency',                     true,   Validator::CURRENCY],
      ['address1',               'payment.billingAddress.firstLine',     true,   Validator::MEDIUM_STRING],
      ['city',                   'payment.billingAddress.city',          true,   Validator::MEDIUM_STRING],
      ['zip_code',               'payment.billingAddress.zipCode',       true,   Validator::ZIP_CODE],
      ['country',                'payment.billingAddress.country',       true,   Validator::COUNTRY],
      ['phone',                  'payment.billingAddress.phone',         true,   Validator::PHONE],
      ['ipaddress',              'payment.customer.ipAddress',           true,   Validator::IP],
      ['email',                  'payment.customer.email',               true,   Validator::EMAIL],
      ['card_printed_name',      'payment.creditCard.cardPrintedName',   true,   Validator::LONG_STRING],
      ['credit_card_number',     'payment.creditCard.creditCardNumber',  true,   Validator::CREDIT_CARD_NUMBER],
      ['expire_month',           'payment.creditCard.expireMonth',       true,   Validator::MONTH],
      ['expire_year',            'payment.creditCard.expireYear',        true,   Validator::YEAR],
      ['cvv2',                   'payment.creditCard.cvv2',              true,   Validator::CVV2],
      ['redirect_url',           'queryConfig.redirectUrl',              true,   Validator::URL],
      # optional
      ['first_name',             'payment.customer.firstName',           false,  Validator::MEDIUM_STRING],
      ['last_name',              'payment.customer.lastName',            false,  Validator::MEDIUM_STRING],
      ['ssn',                    'payment.customer.ssn',                 false,  Validator::SSN],
      ['birthday',               'payment.customer.birthday',            false,  Validator::DATE],
      ['state',                  'payment.billingAddress.state',         false,  Validator::COUNTRY],
      ['cell_phone',             'payment.billingAddress.cellPhone',     false,  Validator::PHONE],
      ['destination',            'payment.destination',                  false,  Validator::LONG_STRING],
      ['site_url',               'queryConfig.siteUrl',                  false,  Validator::URL],
      ['server_callback_url',    'queryConfig.callbackUrl',              false,  Validator::URL]
    ]

    @@signature_definition =
    [
      'queryConfig.endPoint',
      'payment.clientId',
      'payment.amountInCents',
      'payment.customer.email',
      'queryConfig.signingKey'
    ]

    @@payment_status = Payment::STATUS_CAPTURE
  end
end