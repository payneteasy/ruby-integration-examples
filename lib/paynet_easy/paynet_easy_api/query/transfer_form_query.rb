require 'query/prototype/payment_form_query'
require 'payment_data/payment'

module PaynetEasy::PaynetEasyApi::Query
  class TransferFormQuery < Prototype::PaymentFormQuery
    include PaynetEasy::PaynetEasyApi::PaymentData

    @payment_status = Payment::STATUS_CAPTURE
  end
end