require 'query/prototype/payment_query'
require 'util/validator'
require 'transport/response'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  class PaymentFormQuery < PaymentQuery
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Transport

    @@response_fields_definition =
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
      ['redirect_url',           'queryConfig.redirectUrl',              true,   Validator::URL],
      # optional
      ['first_name',             'payment.customer.firstName',           false,  Validator::MEDIUM_STRING],
      ['last_name',              'payment.customer.lastName',            false,  Validator::MEDIUM_STRING],
      ['ssn',                    'payment.customer.ssn',                 false,  Validator::SSN],
      ['birthday',               'payment.customer.birthday',            false,  Validator::DATE],
      ['state',                  'payment.billingAddress.state',         false,  Validator::COUNTRY],
      ['cell_phone',             'payment.billingAddress.cellPhone',     false,  Validator::PHONE],
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

    @@response_fields_definition =
    [
      'type',
      'status',
      'paynet-order-id',
      'merchant-order-id',
      'serial-number',
      'redirect-url'
    ]

    @@success_response_type = 'async-form-response'

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      super payment_transaction, response

      if response.has_redirect_url?
        response.needed_action = Response::NEEDED_REDIRECT
      end
    end
  end
end