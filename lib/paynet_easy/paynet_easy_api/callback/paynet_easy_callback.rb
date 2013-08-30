require 'callback/callback_prototype'
require 'payment_data/payment_transaction'

module PaynetEasy::PaynetEasyApi::Callback
  class PaynetEasyCallback < CallbackPrototype
    include PaynetEasy::PaynetEasyApi::PaymentData

    @callback_fields_definition =
    [
      ['orderid',        'payment.paynet_id'],
      ['merchant_order', 'payment.client_id'],
      ['client_orderid', 'payment.client_id'],
      ['amount',         'payment.amount'],
      ['status',          nil],
      ['type',            nil],
      ['control',         nil]
    ]

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    callback_response     [CallbackResponse]      PaynetEasy callback
    #
    # @return                         [CallbackResponse]      PaynetEasy callback
    def process_callback(payment_transaction, callback_response)
      payment_transaction.processor_type = PaymentTransaction::PROCESSOR_CALLBACK
      payment_transaction.processor_name = @callback_type

      super payment_transaction, callback_response
    end

    protected

    # Validates callback
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    callback_response     [CallbackResponse]      Callback from PaynetEasy
    def validate_callback(payment_transaction, callback_response)
      unless payment_transaction.new?
        raise ValidationError, 'Only new payment transaction can be processed'
      end

      super payment_transaction, callback_response
    end
  end
end
