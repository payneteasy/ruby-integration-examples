require 'query/prototype/payment_query'
require 'util/validator'
require 'transport/response'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  class PaymentFormQuery < PaymentQuery
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Transport

    @request_fields_definition =
    [
      # mandatory
      ['client_orderid',         'payment.client_id',                    true,   Validator::ID],
      ['order_desc',             'payment.description',                  true,   Validator::LONG_STRING],
      ['amount',                 'payment.amount',                       true,   Validator::AMOUNT],
      ['currency',               'payment.currency',                     true,   Validator::CURRENCY],
      ['address1',               'payment.billing_address.first_line',   true,   Validator::MEDIUM_STRING],
      ['city',                   'payment.billing_address.city',         true,   Validator::MEDIUM_STRING],
      ['zip_code',               'payment.billing_address.zip_code',     true,   Validator::ZIP_CODE],
      ['country',                'payment.billing_address.country',      true,   Validator::COUNTRY],
      ['phone',                  'payment.billing_address.phone',        true,   Validator::PHONE],
      ['ipaddress',              'payment.customer.ip_address',          true,   Validator::IP],
      ['email',                  'payment.customer.email',               true,   Validator::EMAIL],
      ['redirect_url',           'query_config.redirect_url',            true,   Validator::URL],
      # optional
      ['first_name',             'payment.customer.first_name',          false,  Validator::MEDIUM_STRING],
      ['last_name',              'payment.customer.last_name',           false,  Validator::MEDIUM_STRING],
      ['ssn',                    'payment.customer.ssn',                 false,  Validator::SSN],
      ['birthday',               'payment.customer.birthday',            false,  Validator::DATE],
      ['state',                  'payment.billing_address.state',        false,  Validator::COUNTRY],
      ['cell_phone',             'payment.billing_address.cell_phone',   false,  Validator::PHONE],
      ['site_url',               'query_config.site_url',                false,  Validator::URL],
      ['server_callback_url',    'query_config.callback_url',            false,  Validator::URL]
    ]

    @signature_definition =
    [
      'query_config.end_point',
      'payment.client_id',
      'payment.amount_in_cents',
      'payment.customer.email',
      'query_config.signing_key'
    ]

    @response_fields_definition =
    [
      'type',
      'status',
      'paynet-order-id',
      'merchant-order-id',
      'serial-number',
      'redirect-url'
    ]

    @success_response_type = 'async-form-response'

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