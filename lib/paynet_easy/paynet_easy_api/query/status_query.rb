require 'query/prototype/query'
require 'transport/response'

module PaynetEasy::PaynetEasyApi::Query
  class StatusQuery < Prototype::Query
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Transport

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',     'payment.clientId',                 true,    Validator::ID],
      ['orderid',            'payment.paynetId',                 true,    Validator::ID],
      ['login',              'queryConfig.login',                true,    Validator::MEDIUM_STRING]
    ]

    @@signature_definition =
    [
      'queryConfig.login',
      'payment.clientId',
      'payment.paynetId',
      'queryConfig.signingKey'
    ]

    @@response_fields_definition =
    [
      'type',
      'status',
      'paynet-order-id',
      'merchant-order-id',
      'serial-number'
    ]

    @@success_response_type = 'status-response'

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      super payment_transaction, response

      if response.has_html?
        response.needed_action = Response::NEEDED_SHOW_HTML
      elsif response.processing?
        response.needed_action = Response::NEEDED_STATUS_UPDATE
      end
    end
  end
end
