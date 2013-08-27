require_relative './query_test'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  class PaymentQueryTest < QueryTest
    def initialize(test_name)
      super test_name
      @success_type   = 'async-response'
      @api_method     = ''      # For IDE autocomplete
      @payment_status = ''      # For IDE autocomplete
    end

    def setup
      raise NotImplementedError, 'You must implement @object creation in this method'
      @object = Query.new ''  # For IDE autocomplete
    end

    def assert_create_request(control_code)
      payment_transaction, request = super control_code
      payment = payment_transaction.payment

      assert_true payment.has_processing_transaction?
      assert_equal @payment_status, payment.status
      assert_equal PaymentTransaction::PROCESSOR_QUERY, payment_transaction.processor_type
      assert_equal @api_method, payment_transaction.processor_name

      [payment_transaction, request]
    end

    def test_create_request_with_processing_payment
      payment_transaction = payment_transaction()
      payment_transaction.status = PaymentTransaction::STATUS_PROCESSING

      assert_raise ValidationError, 'Payment can not has processing payment transaction' do
        @object.create_request payment_transaction
      end
    end

    def test_create_request_with_finished_transaction
      payment_transaction = payment_transaction()
      payment_transaction.status = PaymentTransaction::STATUS_APPROVED

      assert_raise ValidationError, 'Payment transaction must be new' do
        @object.create_request payment_transaction
      end
    end

    def test_process_response_processing
      [
        {
          'type'              => @success_type,
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_'
        }
      ].each do |response|
        assert_process_response_processing response
      end
    end

    def assert_process_response_processing(response)
      payment_transaction = payment_transaction()
      response_object = Response.new response

      @object.process_response payment_transaction, response_object

      assert_equal PAYNET_ID, payment_transaction.payment.paynet_id
      assert_true payment_transaction.processing?
      assert_false payment_transaction.finished?
      assert_false payment_transaction.has_errors?

      [payment_transaction, response_object]
    end

    def test_process_response_error
      [
        {
          'type'              => 'validation-error',
          'serial-number'     => '_',
          'error-message'     => 'validation-error message',
          'error-code'        =>  1
        },
        {
          'type'              => 'error',
          'error-message'     => 'test type error message',
          'error-code'        =>  5
        }
      ].each do |response|
        assert_process_response_error response
      end
    end

    def test_validate_client_id_with_different_types
      payment_transaction = payment_transaction()
      payment_transaction.payment.client_id = 123

      response = Response.new(
      {
        'type'              => @success_type,
        'status'            => 'approved',
        'paynet-order-id'   =>  PAYNET_ID,
        'merchant-order-id' => '123',
        'serial-number'     => '_',
        'redirect-url'      => 'http://example.com'
      })

      @object.process_response payment_transaction, response

      assert_true payment_transaction.approved?
    end
  end
end
