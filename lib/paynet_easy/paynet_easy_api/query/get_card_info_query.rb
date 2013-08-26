require 'query/prototype/query'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class GetCardInfoQuery < Prototype::Query
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['cardrefid',          'payment.recurrentCardFrom.paynetId',           true,    Validator::ID],
      ['login',              'queryConfig.login',                            true,    Validator::MEDIUM_STRING]
    ]

    @@signature_definition =
    [
      'queryConfig.login',
      'payment.recurrentCardFrom.paynetId',
      'queryConfig.signingKey'
    ]

    @@response_fields_definition =
    [
      'type',
      'card-printed-name',
      'expire-year',
      'expire-month',
      'bin',
      'last-four-digits',
      'serial-number'
    ]

    @@success_response_type = 'get-card-info-response'

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      recurrent_card = payment_transaction.payment.recurrent_card_from

      recurrent_card.card_printed_name  = response['card-printed-name']
      recurrent_card.expire_year        = response['expire-year']
      recurrent_card.expire_month       = response['expire-month']
      recurrent_card.bin                = response['bin']
      recurrent_card.last_four_digits   = response['last-four-digits']
    end
  end
end