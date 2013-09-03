require_relative './prototype/sync_query_test_prototype'
require 'query/create_card_ref_query'

module PaynetEasy::PaynetEasyApi::Query
  class CreateCardRefQueryTest < Test::Unit::TestCase
    include Prototype::SyncQueryTestPrototype

    def test_create_request
      [
        create_control_code(
          LOGIN,
          CLIENT_ID,
          PAYNET_ID,
          SIGNING_KEY
        )
      ].each do |control_code|
        assert_create_request control_code
      end
    end

    def test_create_request_with_empty_fields
      payment_transaction = PaymentTransaction.new(
      {
        'payment'       => Payment.new(
        {
          'status'        => Payment::STATUS_CAPTURE
        }),
        'query_config'  => QueryConfig.new(
        {
          'signing_key'   => SIGNING_KEY
        }),
        'status'        => PaymentTransaction::STATUS_APPROVED
      })

      assert_raise ValidationError, 'Some required fields missed or empty in Payment' do
        query.create_request payment_transaction
      end
    end

    alias :sync_query_test_payment_transaction :payment_transaction

    def test_create_request_with_not_ended_payment
      assert_raise ValidationError, 'Only finished payment transaction can be used for create-card-ref-id' do
        query.create_request sync_query_test_payment_transaction
      end
    end

    def test_create_request_with_new_payment
      payment = Payment.new(
      {
        'client_id' => CLIENT_ID,
        'paynet_id' => PAYNET_ID
      })

      payment_transaction = payment_transaction()
      payment_transaction.payment = payment

      assert_raise ValidationError, 'Can not use new payment for create-card-ref-id' do
        query.create_request payment_transaction
      end
    end

    def test_process_success_response_with_empty_fields
      response = Response.new(
      {
        'type'              =>  success_type,
        'status'            => 'processing',
        'paynet-order-id'   =>  PAYNET_ID,
        'merchant-order-id' =>  CLIENT_ID,
        'serial-number'     => '_'
      })

      assert_raise ValidationError, 'Some required fields missed or empty in Response: card-ref-id' do
        query.process_response payment_transaction, response
      end
    end

    def test_process_response_approved
      [
        {
          'type'              =>  success_type,
          'status'            => 'approved',
          'card-ref-id'       =>  RECURRENT_CARD_FROM_ID,
          'serial-number'     => '_'
        }
      ].each do |response|
        assert_process_response_approved response
      end
    end

    protected

    def payment_transaction
      payment_transaction = sync_query_test_payment_transaction
      payment_transaction.status = PaymentTransaction::STATUS_APPROVED
      payment_transaction
    end

    def payment
      Payment.new(
      {
        'client_id'             => CLIENT_ID,
        'paynet_id'             => PAYNET_ID,
        'status'                => Payment::STATUS_PREAUTH
      })
    end

    def success_type
      'create-card-ref-response'
    end

    def query
      CreateCardRefQuery.new '_'
    end
  end
end