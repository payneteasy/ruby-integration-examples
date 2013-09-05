require 'query/prototype/query'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  class PaymentQuery < Query
    # Status for payment, when it is processing by this query
    @payment_status = ''

    @response_fields_definition =
    [
      'type',
      'status',
      'paynet-order-id',
      'merchant-order-id',
      'serial-number'
    ]

    @success_response_type = 'async-response'

    class << self;
      protected

      # @return   [String]
      def payment_status
        @payment_status
      end
    end

      # @param    payment_transaction   [PaymentTransaction]
    #
    # @return                         [Request]
    def create_request(payment_transaction)
      request = super payment_transaction

      payment_transaction.payment.status  = payment_status
      payment_transaction.processor_type  = PaymentTransaction::PROCESSOR_QUERY
      payment_transaction.processor_name  = @api_method
      payment_transaction.status          = PaymentTransaction::STATUS_PROCESSING

      request
    end

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      super payment_transaction, response

      if response.processing?
        response.needed_action = Response::NEEDED_STATUS_UPDATE
      end
    end

    # @param    payment_transaction   [PaymentTransaction]
    def validate_payment_transaction(payment_transaction)
      if payment_transaction.payment.has_processing_transaction?
        raise ValidationError, 'Payment can not has processing payment transaction'
      end

      unless payment_transaction.new?
        raise ValidationError, 'Payment transaction must be new'
      end

      super payment_transaction
    end

    def validate_query_definition
      super

      unless payment_status
        raise RuntimeError, 'You must configure @payment_status'
      end
    end

    # @return   [String]
    def payment_status
      self.class.instance_variable_get :@payment_status
    end
  end
end
