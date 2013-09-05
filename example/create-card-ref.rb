#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData

start_session

# Обратите внимание, что для выполнения этого запроса необходимо сначала провести
# платеж одним из следующих способов: sale, preauth, sale-form, preauth-form
#
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Card_Registration
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Process_Initial_Payment
#
# Создадим новый платеж.
#
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions#Card_registration_request_parameters
# @see PaynetEasy::PaynetEasyApi::Query::CreateCardRefQuery, @request_fields_definition
# @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
# @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
# @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
# @see common/functions.rb, query_config()
payment_transaction = PaymentTransaction.new(
{
  'payment'               => Payment.new(
  {
    'client_id'             => 'CLIENT-112244',
    'paynet_id'             =>  1969595,
    'status'                =>  Payment::STATUS_PREAUTH
  }),
  'status'                =>  PaymentTransaction::STATUS_APPROVED,
  'query_config'          =>  query_config
})

# Вызов этого метода создаст в объекте Payment объект RecurrentCard
#
# @see PaynetEasy::PaynetEasyApi::Query::CreateCardRefQuery.update_payment_on_success()
payment_processor.execute_query 'create-card-ref', payment_transaction
