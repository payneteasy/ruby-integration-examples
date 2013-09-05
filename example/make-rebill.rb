#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData

start_session

# Первый этап обработки платежа.
# Создание нового платежа, выполнение запроса make-rebill.
if !$_GET.key? 'stage'
  # Обратите внимание, что для выполнения этого запроса необходимо сначала
  # получить id кредитной карты, выполнив запрос create-card-ref
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Process_Recurrent_Payment
  # @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Card_Registration
  # @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Process_Initial_Payment
  #
  # Создадим новый платеж.
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Recurrent_Payment_request_parameters
  # @see PaynetEasy::PaynetEasyApi::Query::MakeRebillQuery, @request_fields_definition
  # @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Customer
  # @see PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard
  # @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
  # @see common/functions.rb, query_config()
  payment_transaction = PaymentTransaction.new(
  {
    'payment'               => Payment.new(
    {
      'client_id'             => 'CLIENT-112244',
      'description'           => 'This is test payment',
      'amount'                =>  0.99,
      'currency'              => 'USD',
      'customer'              =>  Customer.new(
      {
        'ip_address'            => '127.0.0.1'
      }),
      'recurrent_card_from'   => RecurrentCard.new(
      {
        'paynet_id'             => 8058
      })
    }),
    'query_config'          =>  query_config
  })

  # Выполним запрос make-rebill
  #
  # @see PaynetEasy::PaynetEasyApi::PaymentProcessor.execute_query()
  # @see PaynetEasy::PaynetEasyApi::Query::MakeRebillQuery.update_payment_on_success()
  payment_processor.execute_query 'make-rebill', payment_transaction

# Второй этап обработки платежа.
# Ожидание изменения статуса платежа.
elsif $_GET['stage'] == 'updateStatus'
  # Запросим статус платежа
  payment_processor.execute_query 'status', load_payment_transaction
end
