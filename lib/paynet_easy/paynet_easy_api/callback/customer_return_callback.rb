require 'callback/callback_prototype'

module PaynetEasy::PaynetEasyApi::Callback
  class CustomerReturnCallback < CallbackPrototype
    @callback_fields_definition =
    [
      ['orderid',        'payment.paynet_id'],
      ['merchant_order', 'payment.client_id'],
      ['client_orderid', 'payment.client_id'],
      ['status',          nil],
      ['control',         nil]
    ]

    protected

    # Validates callback
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    callback_response     [CallbackResponse]      Callback from PaynetEasy
    def validate_callback(payment_transaction, callback_response)
      unless payment_transaction.processing?
        raise ValidationError, 'Only processing payment transaction can be processed'
      end

      super payment_transaction, callback_response
    end
  end
end
