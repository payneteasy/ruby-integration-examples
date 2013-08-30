require 'digest/sha1'
require 'payment_data/payment_transaction'
require 'transport/callback_response'
require 'error/validation_error'
require 'util/property_accessor'

module PaynetEasy::PaynetEasyApi::Callback
  class CallbackPrototype
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Error
    include PaynetEasy::PaynetEasyApi::Util

    # Allowed callback statuses
    @allowed_statuses =
    [
      PaymentTransaction::STATUS_APPROVED,
      PaymentTransaction::STATUS_DECLINED,
      PaymentTransaction::STATUS_FILTERED,
      PaymentTransaction::STATUS_ERROR
    ]

    # Callback fields definition if format:
    # [
    #   [<first callback field name>:string, <first payment transaction property path>:string]
    #   [<second callback field name>:string, <second payment transaction property path>:string]
    #   ...
    #   [<last callback field name>:string, <last payment transaction property path>:string]
    # ]
    #
    # If property name present in field definition,
    # callback response field value and payment transaction property value will be compared.
    # If values not equal validation exception will be raised.
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

    def initialize(callback_type)
      @callback_type = callback_type
      validate_callback_definition
    end

    # Process API gateway Response and update Payment transaction
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    callback_response     [CallbackResponse]      PaynetEasy callback
    #
    # @return                         [CallbackResponse]      PaynetEasy callback
    def process_callback(payment_transaction, callback_response)
      begin
        validate_callback payment_transaction, callback_response
      rescue Exception => error
        payment_transaction.add_error error
        payment_transaction.status = PaymentTransaction::STATUS_ERROR

        raise error
      end

      update_payment_transaction payment_transaction, callback_response

      if callback_response.error?
        raise callback_response.error
      end

      callback_response
    end

    protected

    # Validates callback
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    callback_response     [CallbackResponse]      Callback from PaynetEasy
    def validate_callback(payment_transaction, callback_response)
      validate_query_config payment_transaction
      validate_signature payment_transaction, callback_response

      unless allowed_statuses.include? callback_response.status
        raise ValidationError, "Invalid callback status: '#{callback_response.status}'"
      end

      error_message   = ''
      missed_fields   = []
      unequal_fields  = []

      callback_fields_definition.each do |field_name, property_path|
        if callback_response.fetch(field_name, nil).nil?
          missed_fields << field_name
        elsif property_path
          property_value = PropertyAccessor.get_value payment_transaction, property_path, false
          callback_value = callback_response.fetch field_name

          if property_value.to_s != callback_value.to_s
            unequal_fields << "CallbackResponse field '#{field_name}' value '#{callback_value}' does not " +
                              "equal PaymentTransaction property '#{property_path}' value '#{property_value}'."
          end
        end
      end

      unless missed_fields.empty?
        error_message << "Some required fields missed or empty in CallbackResponse: \n#{missed_fields.join(', ')}. \n"
      end

      unless unequal_fields.empty?
        error_message << "Some fields from CallbackResponse unequal properties " +
                         "from PaymentTransaction: \n#{unequal_fields.join(" \n")}"
      end

      unless error_message.empty?
        raise ValidationError, error_message
      end
    end

    # Validates payment transaction query config
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    def validate_query_config(payment_transaction)
      unless payment_transaction.query_config.signing_key
        raise ValidationError, "Property 'signing_key' does not defined in PaymentTransaction property 'query_config'"
      end
    end

    # Validate callback response control code
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for control code checking
    # @param    callback_response     [CallbackResponse]      Callback for control code checking
    def validate_signature(payment_transaction, callback_response)
      expected_control_code = Digest::SHA1.hexdigest(
        callback_response.status +
        callback_response.payment_paynet_id.to_s +
        callback_response.payment_client_id.to_s +
        payment_transaction.query_config.signing_key
      )

      if expected_control_code != callback_response.control_code
        raise ValidationError, "Actual control code '#{callback_response.control_code}' does " +
                               "not equal expected '#{expected_control_code}'"
      end
    end

    # Updates Payment transaction by Callback data
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for updating
    # @param    callback_response     [CallbackResponse]      Callback for payment transaction updating
    def update_payment_transaction(payment_transaction, callback_response)
      payment_transaction.status = callback_response.status
      payment_transaction.payment.paynet_id = callback_response.payment_paynet_id

      if callback_response.error? || callback_response.declined?
        payment_transaction.add_error callback_response.error
      end
    end

    # Validates callback object definition
    def validate_callback_definition
      raise RuntimeError, 'You must configure @allowed_statuses'            if allowed_statuses.empty?
      raise RuntimeError, 'You must configure @callback_fields_definition'  if callback_fields_definition.empty?
    end

    class << self
      # Make instance variables available in child classes
      def inherited(subclass)
        instance_variables.each do |variable_name|
          subclass.instance_variable_set variable_name, instance_variable_get(variable_name)
        end
      end
    end

    # @return   [Array]
    def allowed_statuses
      self.class.instance_variable_get :@allowed_statuses
    end

    # @return   [Array]
    def callback_fields_definition
      self.class.instance_variable_get :@callback_fields_definition
    end
  end
end