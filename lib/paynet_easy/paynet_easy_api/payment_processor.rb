require 'contracts'
require 'payment_data/payment_transaction'
require 'query/query_factory'
require 'query/prototype/query'
require 'callback/callback_factory'
require 'callback/callback_prototype'
require 'transport/gateway_client'
require 'transport/request'
require 'transport/response'
require 'transport/callback_response'

module PaynetEasy::PaynetEasyApi
  class PaymentProcessor
    include Contracts
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Query
    include PaynetEasy::PaynetEasyApi::Callback

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

    attr_accessor :gateway_client
    attr_accessor :query_factory
    attr_accessor :callback_factory

    Contract Array => Any
    def initialize(handlers = {})
      @handlers = {}
      set_handlers handlers
    end

    Contract String, PaymentTransaction => Maybe[Response]
    # Executes payment API query
    #
    # @param    query_name            [String]                Payment API query name
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for processing
    #
    # @return                         [Response]              Query response
    def execute_query(query_name, payment_transaction)
      query = query(query_name)

      begin
        request = query.create_request payment_transaction
        response = make_request request
        query.process_response payment_transaction, response
      rescue Exception => error
        handle_exception error, payment_transaction, response
        return
      end

      handle_query_result payment_transaction, response

      response
    end

    Contract CallbackResponse, PaymentTransaction => Maybe[CallbackResponse]
    # Executes payment gateway processor for customer return from payment form or 3D-auth
    #
    # @param    callback_response     [CallbackResponse]      Callback object with data from payment gateway
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for processing
    #
    # @return                         [CallbackResponse]      Validated payment gateway callback
    def process_customer_return(callback_response, payment_transaction)
      callback_response.type = 'customer_return'
      process_paynet_easy_callback callback_response, payment_transaction
    end

    Contract CallbackResponse, PaymentTransaction => Maybe[CallbackResponse]
    # Executes payment gateway processor for PaynetEasy payment callback
    #
    # @param    callback_response     [CallbackResponse]      Callback object with data from payment gateway
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for processing
    #
    # @return                         [CallbackResponse]      Validated payment gateway callback
    def process_paynet_easy_callback(callback_response, payment_transaction)
      begin
        callback(callback_response.type).process_callback(payment_transaction, callback_response)
      rescue Exception => error
        handle_exception error, payment_transaction, callback_response
        return
      end

      handle_query_result payment_transaction, callback_response

      callback_response
    end

    Contract String => IsA[Prototype::Query]
    # Create API query object by API query method
    #
    # @param    api_query_name    [String]              API query method
    #
    # @return                     [Prototype::Query]    API query object
    def query(api_query_name)
      query_factory.query api_query_name
    end

    Contract String => IsA[CallbackPrototype]
    # Create API callback processor by callback response
    #
    # @param    callback_type   [String]              Callback response type
    #
    # @return                   [CallbackPrototype]   Callback processor
    def callback(callback_type)
      callback_factory.callback callback_type
    end

    Contract Request => Response
    # Make request to the PaynetEasy gateway
    #
    # @param    request   [Request]     Request data
    #
    # @return             [Response]    Response data
    def make_request(request)
      gateway_client.make_request request
    end

    Contract String, Proc => Any
    # Set handler callback for processing action.
    #
    # @param    handler_name        [String]    Handler name
    # @param    handler_callback    [Proc]      Handler callback
    def set_handler(handler_name, &handler_callback)
      check_handler_name handler_name

      @handlers[handler_name] = handler_callback
    end

    Contract Hash => Any
    # Set handlers. Handlers array must follow new format:
    # {<handlerName>:String => <handlerCallback>:Proc}
    #
    # @param    handlers    [Hash]    Handlers callbacks
    def set_handlers(handlers = {})
      handlers.each {|handler_name, handler_callback| set_handler handler_name, &handler_callback}
    end

    Contract String => Any
    # Remove handler for processing action
    #
    # @param    handler_name    [String]    Handler name
    def remove_handler(handler_name)
      check_handler_name handler_name

      @handlers.delete handler_name
    end

    # Remove all handlers
    def remove_handlers
      @handlers = {}
    end

    Contract None => IsA[GatewayClient]
    def gateway_client
      @gateway_client ||= GatewayClient.new
    end

    Contract None => IsA[QueryFactory]
    def query_factory
      @query_factory ||= QueryFactory.new
    end

    Contract None => IsA[CallbackFactory]
    def callback_factory
      @callback_factory ||= CallbackFactory.new
    end

    protected

    Contract PaymentTransaction, IsA[Response] => Any
    # Handle query result.
    # Method calls handlers for:
    #  - HANDLER_SAVE_CHANGES            always
    #  - HANDLER_STATUS_UPDATE           if needed payment transaction status update
    #  - HANDLER_SHOW_HTML               if needed to show response html
    #  - HANDLER_REDIRECT                if needed to redirect to response URL
    #  - HANDLER_FINISH_PROCESSING       if not additional action needed
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Query result
    def handle_query_result(payment_transaction, response)
      call_handler HANDLER_SAVE_CHANGES, payment_transaction, response

      case true
      when response.redirect_needed?
          call_handler HANDLER_REDIRECT, response, payment_transaction
      when response.show_html_needed?
          call_handler HANDLER_SHOW_HTML, response, payment_transaction
      when response.status_update_needed?
          call_handler HANDLER_STATUS_UPDATE, response, payment_transaction
      else
          call_handler HANDLER_FINISH_PROCESSING, payment_transaction, response
      end
    end

    Contract IsA[Exception], PaymentTransaction, Any => Any
    # Handle raised exception. If configured self::HANDLER_CATCH_EXCEPTION, handler will be called,
    # if not - exception will be raised again.
    #
    # @param    error                 [Exception]
    # @param    payment_transaction   [PaymentTransaction]
    # @param    response              [Response]
    def handle_exception(error, payment_transaction, response = nil)
      call_handler HANDLER_SAVE_CHANGES, payment_transaction, response

      raise error unless has_handler? HANDLER_CATCH_EXCEPTION

      call_handler HANDLER_CATCH_EXCEPTION, error, payment_transaction, response
    end

    Contract String, Any => Any
    # Executes handler callback.
    # Method receives at least one parameter - handler name,
    # all other parameters will be passed to handler callback.
    #
    # @param    handler_name    [String]    Handler name
    # @param    args            [Array]     Handler parameters
    def call_handler(handler_name, *args)
      check_handler_name handler_name

      @handlers[handler_name].(*args) if has_handler? handler_name
    end

    Contract String => Any
    # Check if handler name is allowed
    #
    # @param    handler_name    [String]    Handler name
    def check_handler_name(handler_name)
      unless @@allowed_handlers.include? handler_name
        raise RuntimeError, "Unknown handler name: '#{handler_name}'"
      end
    end

    Contract String => Bool
    # True if processor has handler callback for given handler name
    #
    # @param    handler_name    [String]                  Handler name
    #
    # @return                   [TrueClass|FalseClass]    Check result
    def has_handler?(handler_name)
      @handlers.key? handler_name
    end
  end
end