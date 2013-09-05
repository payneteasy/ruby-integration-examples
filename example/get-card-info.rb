#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData

start_session

# Обратите внимание, что для выполнения этого запроса необходимо сначала
# получить id кредитной карты, выполнив запрос create-card-ref
#
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Card_Registration
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Process_Initial_Payment
#
# Создадим новый платеж.
#
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Card_Information_request_parameters
# @see PaynetEasy::PaynetEasyApi::Query::GetCardInfoQuery, @request_fields_definition
# @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
# @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
# @see PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard
# @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
# @see common/functions.rb, query_config()
payment_transaction = PaymentTransaction.new(
{
  'payment'               => Payment.new(
  {
    'recurrent_card_from'   =>  RecurrentCard.new(
    {
      'paynet_id'             => 8058
    })
  }),
  'query_config'          =>  query_config
})

# Вызов этого метода заполнит поля объекта RecurrentCard, размещенного в объекте Payment
#
# @see PaynetEasy::PaynetEasyApi::Query::GetCardInfoQuery.update_payment_on_success()
payment_processor.execute_query 'get-card-info', payment_transaction
