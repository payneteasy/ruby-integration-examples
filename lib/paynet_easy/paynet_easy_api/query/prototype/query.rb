require 'contracts'
require 'digest/sha1'
require 'query/query_interface'
require 'payment_data/payment_transaction'
require 'util/property_accessor'
require 'util/validator'
require 'transport/request'
require 'transport/response'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  class Query
    include Contracts
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Error

    include PaynetEasy::PaynetEasyApi::Query::QueryInterface

    # Request fields definition in format
    # [
    #   [<first field name>:string,  <first property path>:string,   <is field required>:boolean, <validation rule>:string],
    #   [<second field name>:string, <second property path>:string,  <is field required>:boolean, <validation rule>:string],
    #     ...
    #   [<last field name>:string,   <last property path>:string,    <is field required>:boolean, <validation rule>:string]
    # ]
    @@request_fields_definition = []

    # Request control code definition in format
    # [<first part property path>:string, <second part property path>:string ... <last part property path>:string]
    @@signature_definition = []

    # Response fields definition in format:
    # [<first field_name>:string, <second field_name>:string ... <last field_name>:string]
    @@response_fields_definition = []

    # Success response type
    @@success_response_type = ''

    def initialize(api_method)
      @api_method = api_method
    end

    Contract PaymentTransaction => Request
    # Create API gateway request from payment transaction data
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for query
    #
    # @return                         [Request]               Request object
    def create_request(payment_transaction)
      validate_payment_transaction payment_transaction

      request = payment_transaction_to_request payment_transaction

      request.api_method  = @api_method
      request.end_point   = payment_transaction.query_config.end_point
      request.gateway_url = payment_transaction.query_config.gateway_url
      request.signature   = create_signature payment_transaction

      request
    rescue Exception => error
      payment_transaction.add_error error
      payment_transaction.status = PaymentTransaction::STATUS_ERROR

      raise error
    end

    Contract PaymentTransaction, Response => Response
    # Process API gateway response and update payment transaction
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    response              [Response]              API gateway response
    #
    # @return                         [Response]              API gateway response
    def process_response(payment_transaction, response)
      if response.processing? || response.approved?
        validate = :validate_response_on_success
        update   = :update_response_on_success
      else
        validate = :validate_response_on_error
        update   = :update_response_on_error
      end

      begin
        send validate, payment_transaction, response
      rescue Exception => error
        payment_transaction.add_error error
        payment_transaction.status = PaymentTransaction::STATUS_ERROR

        raise error
      end

      send update, payment_transaction, response

      if response.error?
        raise response.error
      end

      response
    end

    protected

    Contract PaymentTransaction => Any
    # Validates payment transaction before request constructing
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for validation
    def validate_payment_transaction(payment_transaction)
      validate_query_config payment_transaction

      error_message   = ''
      missed_fields   = []
      invalid_fields  = []

      @@request_fields_definition.each do |field_name, property_path, is_field_required, validation_rule|
        field_value = PropertyAccessor.get_value payment_transaction, property_path, false

        if field_value
          begin
            Validator.validate_by_rule field_value, validation_rule
          rescue ValidationError => error
            invalid_fields << "Field '#{field_name}' from property path '#{property_path}', #{error.message}."
          end
        elsif is_field_required
          missed_fields << "Field '#{field_name}' from property path '#{property_path}' missed or empty."
        end
      end

      unless missed_fields.empty?
        error_message << "Some required fields missed or empty in PaymentTransaction: \n#{missed_fields.join "\n"}\n"
      end

      unless invalid_fields.empty?
        error_message << "Some fields invalid in PaymentTransaction: \n#{invalid_fields.join "\n"}\n"
      end

      unless error_message.empty?
        raise ValidationError, error_message
      end
    end

    Contract PaymentTransaction => Request
    # Creates request from payment transaction
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for request constructing
    #
    # @return                         [Request]               Request object
    def payment_transaction_to_request(payment_transaction)
      request_fields = {}

      @@request_fields_definition.each do |field_name, property_path, _|
        field_value = PropertyAccessor.get_value payment_transaction, property_path

        if field_value
          request_fields[field_name] = field_value
        end
      end

      Request.new request_fields
    end

    Contract PaymentTransaction => String
    # Generates the control code is used to ensure that it is a particular
    # Merchant (and not a fraudster) that initiates the transaction.
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction to generate control code
    #
    # @return                         [String]                Generated control code
    def create_signature(payment_transaction)
      control_code = ''

      @@signature_definition.each do |property_path|
        control_code << PropertyAccessor.get_value(payment_transaction, property_path)
      end

      Digest::SHA1.hexdigest control_code
    end

    Contract PaymentTransaction, Response => Any
    # Validates response before payment transaction updating
    # if payment transaction is processing or approved
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for validating
    def validate_response_on_success(payment_transaction, response)
      if response.type != @@success_response_type
        raise ValidationError, "Response type '#{response.type}' does " +
                               "not match success response type '#{@@success_response_type}'"
      end

      missed_fields = []

      @@response_fields_definition.each do |field_name|
        missed_fields << field_name unless response.key? field_name
      end

      unless missed_fields.empty?
        raise ValidationError, "Some required fields missed or empty in Response: #{missed_fields.join ', '}"
      end

      validate_client_id payment_transaction, response
    end

    Contract PaymentTransaction, Response => Any
    # Validates response before payment transaction updating
    # if payment transaction is not processing or approved
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for validating
    def validate_response_on_error(payment_transaction, response)
      unless [@@success_response_type, 'error', 'validation-error'].include? response.type
        raise ValidationError, "Unknown response type '#{response.type}'"
      end

      validate_client_id payment_transaction, response
    end

    Contract PaymentTransaction, Response => Any
    # Updates payment transaction by query response data
    # if payment transaction is processing or approved
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      payment_transaction.status = response.status
      set_paynet_id payment_transaction, response
    end

    Contract PaymentTransaction, Response => Any
    # Updates payment transaction by query response data
    # if payment transaction is not processing or approved
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_error(payment_transaction, response)
      if response.declined?
        payment_transaction.status = response.status
      else
        payment_transaction.status = PaymentTransaction::STATUS_ERROR
      end

      payment_transaction.add_error response.error
      set_paynet_id payment_transaction, response
    end

    Contract PaymentTransaction => Any
    # Validates payment transaction query config
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    def validate_query_config(payment_transaction)
      unless payment_transaction.query_config.signing_key
        raise ValidationError, "Property 'signingKey' does not defined in PaymentTransaction property 'queryConfig'"
      end
    end

    # Validates query object definition
    def validate_query_definition
      raise RuntimeError, 'You must configure @@request_fields_definition'  if @@request_fields_definition.empty?
      raise RuntimeError, 'You must configure @@signature_definition'       if @@signature_definition.empty?
      raise RuntimeError, 'You must configure @@response_fields_definition' if @@response_fields_definition.empty?
      raise RuntimeError, 'You must configure @@success_response_type'      if @@success_response_type.nil?
    end

    Contract PaymentTransaction, Response => Any
    # Check, is payment transaction client order id and query response client order id equal or not.
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    response              [Response]              API gateway response
    def validate_client_id(payment_transaction, response)
      payment_id  = payment_transaction.payment.client_id
      response_id = response.payment_client_id

      if response_id && payment_id.to_s != response_id.to_s   # Different types with equal values must pass validation
        raise ValidationError, "Response client_id '#{response_id}' does not match Payment client_id '#{payment_id}'"
      end
    end

    Contract PaymentTransaction, Response => Any
    # Set PaynetEasy payment id to payment transaction Payment
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    response              [Response]              API gateway response
    def set_paynet_id(payment_transaction, response)
      if response.payment_paynet_id
        payment_transaction.payment.paynet_id = response.payment_paynet_id
      end
    end
  end
end