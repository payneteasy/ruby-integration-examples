#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData

start_session

# Первый этап обработки платежа.
# Создание нового платежа, выполнение запроса preauth
if !$_GET.key? 'stage'
  # Создадим новый платеж
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Return_Transactions#Return_Request_Parameters
  # @see PaynetEasy::PaynetEasyApi::Query::ReturnQuery, @request_fields_definition
  # @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
  # @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
  # @see common/functions.rb, query_config()
  payment_transaction = PaymentTransaction.new(
  {
    'payment'       => Payment(
    {
      'client_id'     => 'CLIENT-112244',
      'paynet_id'     =>  1969589,
      'amount'        =>  9.99,
      'currency'      => 'USD',
      'comment'       => 'cancel payment',
      'status'        =>  Payment::STATUS_CAPTURE
    }),
    'query_config'  =>  query_config
  })

  # Выполним запрос return
  #
  # @see PaynetEasy::PaynetEasyApi::PaymentProcessor.execute_query()
  # @see PaynetEasy::PaynetEasyApi::Query::ReturnQuery.update_payment_on_success()
  payment_processor.execute_query 'return', payment_transaction

# Второй этап обработки платежа.
# Ожидание изменения статуса платежа.
elsif $_GET['stage'] == 'updateStatus'
  # Запросим статус платежа
  payment_processor.execute_query 'status', load_payment_transaction
end