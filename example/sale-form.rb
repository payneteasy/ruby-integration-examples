#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Transport

start_session

# Первый этап обработки платежа.
# Создание нового платежа, выполнение запроса sale-form.
if !$_GET.key? 'stage'
  # Создадим новый платеж
  #
  # @see http://wiki.payneteasy.com/index.php/PnE:Payment_Form_integration#Payment_Form_Request_Parameters
  # @see PaynetEasy::PaynetEasyApi::Query::PreauthFormQuery, @request_fields_definition
  # @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
  # @see PaynetEasy::PaynetEasyApi::PaymentData::Customer
  # @see PaynetEasy::PaynetEasyApi::PaymentData::BillingAddress
  # @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
  # @see common/functions.rb, query_config()
  payment_transaction = PaymentTransaction.new(
  {
    'payment'               => Payment.new(
    {
      'client_id'             => 'CLIENT-112244',
      'description'           => 'This is test payment',
      'amount'                =>  9.99,
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
      })
    }),
    'query_config'          =>  query_config
  })

  # Выполним запрос sale-form
  #
  # @see PaynetEasy::PaynetEasyApi::PaymentProcessor.execute_query()
  # @see PaynetEasy::PaynetEasyApi::Query::PreauthFormQuery.update_payment_on_success()
  payment_processor.execute_query 'sale-form', payment_transaction

# Второй этап обработки платежа.
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