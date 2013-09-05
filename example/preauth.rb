#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Transport

start_session

# Первый этап обработки платежа.
# Создание нового платежа, выполнение запроса preauth
if !$_GET.key? 'stage'
  # Создадим новый платеж
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Preauth/Capture_Transactions#Preauth_Request_Parameters
  # @see PaynetEasy::PaynetEasyApi::Query::PreauthQuery, @request_fields_definition
  # @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Customer
  # @see PaynetEasy::PaynetEasyApi::PaymentData::BillingAddress
  # @see PaynetEasy::PaynetEasyApi::PaymentData::CreditCard
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
      'customer'              => Customer.new(
      {
        'email'                 => 'vass.pupkin@example.com',
        'ip_address'            => '127.0.0.1'
      }),
      'billing_address'       => BillingAddress.new(
      {
        'country'               => 'US',
        'state'                 => 'TX',
        'city'                  => 'Houston',
        'first_line'            => '2704 Colonial Drive',
        'zip_code'              => '1235',
        'phone'                 => '660-485-6353'
      }),
      'credit_card'           => CreditCard.new(
      {
        'card_printed_name'     => 'Vasya Pupkin',
        'credit_card_number'    => '4444 5555 6666 1111',
        'expire_month'          => '12',
        'expire_year'           => '14',
        'cvv2'                  => '123'
      })
    }),
    'query_config'          =>  query_config
  })

  # Выполним запрос preauth
  #
  # @see PaynetEasy::PaynetEasyApi::PaymentProcessor.execute_query()
  # @see PaynetEasy::PaynetEasyApi::Query::PreauthQuery.update_payment_on_success()
  payment_processor.execute_query 'preauth', payment_transaction

# Второй этап обработки платежа.
# Ожидание изменения статуса платежа.
elsif $_GET['stage'] == 'updateStatus'
  # Запросим статус платежа
  payment_processor.execute_query 'status', load_payment_transaction

# Третий этап обработки платежа.
# Обработка возврата пользователя от PaynetEasy
elsif $_GET['stage'] == 'processCustomerReturn'
  # Обработаем данные, полученные от PaynetEasy
  payment_processor.process_customer_return CallbackResponse.new($_POST), load_payment_transaction

# Дополнительный этап обработки платежа.
# Обработка коллбэка от PaynetEasy.
elsif $_GET['stage'] == 'processPaynetEasyCallback'
  # Обработаем данные, полученные от PaynetEasy
  payment_processor.process_paynet_easy_callback CallbackResponse.new($_GET), load_payment_transaction
end