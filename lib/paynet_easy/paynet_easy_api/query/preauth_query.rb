require 'query/sale_query'
require 'payment_data/payment'

module PaynetEasy::PaynetEasyApi::Query
  class PreauthQuery < SaleQuery
    include PaynetEasy::PaynetEasyApi::PaymentData

    @payment_status = Payment::STATUS_PREAUTH
  end
end