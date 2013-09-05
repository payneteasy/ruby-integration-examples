#!/usr/bin/ruby

require 'paynet_easy_api'
require_relative './common/functions'

include PaynetEasy::PaynetEasyApi::PaymentData
include PaynetEasy::PaynetEasyApi::Transport

start_session

# Обратите внимание, что для выполнения этого запроса необходимо сначала
# выполнить любой запрос, который подразумевает асинхронную обработку:
# sale, preauth, capture, transfer-by-ref, make-rebill, return
#
# @see http://wiki.payneteasy.com/index.php/PnE:Sale_Transactions
# @see http://wiki.payneteasy.com/index.php/PnE:Preauth/Capture_Transactions
# @see http://wiki.payneteasy.com/index.php/PnE:Transfer_Transactions
# @see http://wiki.payneteasy.com/index.php/PnE:Recurrent_Transactions
# @see http://wiki.payneteasy.com/index.php/PnE:Return_Transactions
#
# Если платеж был сохранен - получим его сохраненную версию, иначе создадим новый.
                                                                                #
# @see http://wiki.payneteasy.com/index.php/PnE:Sale_Transactions#Payment_status_call_parameters
# @see PaynetEasy::PaynetEasyApi::Query::StatusQuery, @request_fields_definition
# @see PaynetEasy::PaynetEasyApi::PaymentData::PaymentTransaction
# @see PaynetEasy::PaynetEasyApi::PaymentData::Payment
# @see PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig
# @see common/functions.rb, query_config()
payment_transaction = load_payment_transaction || PaymentTransaction.new(
{
  'payment'       => Payment.new(
  {
    'client_id'     => 'CLIENT-112244',
    'paynet_id'     =>  1969595
  }),
  'query_config'  => query_config
})

# Вызов этого метода обновит статус обработки платежа
#
# @see PaynetEasy::PaynetEasyApi::Query::Status.update_payment_on_success()
payment_processor.execute_query 'status', payment_transaction
