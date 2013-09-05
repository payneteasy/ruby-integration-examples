#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData

start_session

# Первый этап обработки платежа.
# Создание нового платежа, выполнение запроса transfer-by-ref
if !$_GET.key? 'stage'
  # Создадим новый платеж
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Transfer_Transactions#Money_transfer_request_parameters
  # @see PaynetEasy::PaynetEasyApi::Query::TransferByRefQuery, @request_fields_definition
  # @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Customer
  # @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
  # @see PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard
  # @see common/functions.php, query_config()
  payment_transaction = PaymentTransaction.new(
  {
    'payment'               => Payment.new(
    {
      'client_id'             => 'CLIENT-112244',
      'amount'                =>  9.99,
      'currency'              => 'USD',
      'customer'              =>  Customer.new(
      {
        'ip_address'            => '127.0.0.1'
      }),
      'recurrent_card_from'   =>  RecurrentCard.new(
      {
        'paynet_id'             => 8058,
        'cvv2'                  => 123
      }),
      'recurrent_card_to'     =>  RecurrentCard.new(
      {
        'paynet_id'             => 8059
      }),
    }),
    'query_config'          =>  query_config
  })

  # Выполним запрос transfer-by-ref
  #
  # @see PaynetEasy::PaynetEasyApi::PaymentProcessor.execute_query()
  # @see PaynetEasy::PaynetEasyApi::Query::TransferByRefQuery.update_payment_on_success()
  payment_processor.execute_query 'transfer-by-ref', payment_transaction

# Второй этап обработки платежа.
# Ожидание изменения статуса платежа.
elsif $_GET['stage'] == 'updateStatus'
  # Запросим статус платежа
  payment_processor.execute_query 'status', load_payment_transaction
end