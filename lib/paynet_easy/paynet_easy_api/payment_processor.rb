require 'contracts'
require 'payment_data/payment_transaction'
require 'transport/response'
require 'transport/callback_response'

module PaynetEasy::PaynetEasyApi
  class PaymentProcessor
    include Contracts
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport

    # Payment changed and should be saved
    HANDLER_SAVE_CHANGES      = 'save_payment'

    # Payment status not changed and should be updated
    HANDLER_STATUS_UPDATE     = 'status_update'

    # Html received and should be displayed
    HANDLER_SHOW_HTML         = 'show_html'

    # Redirect url received, customer should be to it
    HANDLER_REDIRECT          = 'redirect'

    # Payment processing ended
    HANDLER_FINISH_PROCESSING = 'finish_processing'

    # Exception handle needed
    HANDLER_CATCH_EXCEPTION   = 'catch_exception'

    # Allowed handlers list
    @@allowed_handlers =
    [
      HANDLER_SAVE_CHANGES,
      HANDLER_STATUS_UPDATE,
      HANDLER_SHOW_HTML,
      HANDLER_REDIRECT,
      HANDLER_FINISH_PROCESSING,
      HANDLER_CATCH_EXCEPTION
    ]

    attr_writer :handlers

    Contract Array => Any
    def initialize(handlers = [])
      self.handlers = handlers
    end

    Contract String, PaymentTransaction => Maybe[Response]
    def execute_query(query_name, payment_transaction)

    end

    Contract CallbackResponse, PaymentTransaction => CallbackResponse
    def process_customer_return(callback_response, payment_transaction)

    end
  end
end