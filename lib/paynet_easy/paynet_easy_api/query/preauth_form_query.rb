require 'query/prototype/payment_form_query'
require 'payment_data/payment'

module PaynetEasy::PaynetEasyApi::Query
  class PreauthFormQuery < Prototype::PaymentFormQuery
    include PaynetEasy::PaynetEasyApi::PaymentData

    @payment_status = Payment::STATUS_PREAUTH
  end
end