require_relative './query_test_prototype'

module PaynetEasy::PaynetEasyApi::Query::Prototype
  module SyncQueryTestPrototype
    include QueryTestPrototype
    
    def test_process_response_approved
      raise NotImplementedError
    end

    def assert_process_response_approved(response)
      payment_transaction = payment_transaction()
      response_object     = Response.new response

      query.process_response payment_transaction, response_object

      assert_true payment_transaction.approved?
      assert_true payment_transaction.finished?
      assert_false payment_transaction.has_errors?

      [payment_transaction, response_object]
    end

    def test_process_response_declined
      [
        {
          'type'              =>  success_type,
          'status'            => 'filtered',
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_',
          'error-message'     => 'test filtered message',
          'error-code'        =>  8876
        },
        {
          'type'              =>  success_type,
          'status'            => 'declined',
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_',
          'error-message'     => 'test error message',
          'error-code'        =>  578
        }
      ].each do |response|
        assert_process_response_declined response
      end
    end

    def assert_process_response_declined(response)
      payment_transaction = payment_transaction()
      response_object     = Response.new response

      query.process_response payment_transaction, response_object

      assert_true payment_transaction.declined?
      assert_true payment_transaction.finished?
      assert_true payment_transaction.has_errors?

      [payment_transaction, response_object]
    end

    def test_process_response_error
      [
        {
          'type'              =>  success_type,
          'status'            => 'error',
          'paynet-order-id'   =>  PAYNET_ID,
          'merchant-order-id' =>  CLIENT_ID,
          'serial-number'     => '_',
          'error-message'     => 'status error message',
          'error-code'        =>  24
        },
        {
          'type'              => 'validation-error',
          'error-message'     => 'validation error message',
          'error-code'        =>  1
        },
        {
          'type'              => 'error',
          'error-message'     => 'immediate error message',
          'error-code'        =>  1
        }
      ].each do |response|
        assert_process_response_error response
      end
    end
  end
end
