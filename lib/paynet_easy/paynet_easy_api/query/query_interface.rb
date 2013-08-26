require 'contracts'
require 'payment_data/payment_transaction'
require 'transport/request'
require 'transport/response'

module PaynetEasy::PaynetEasyApi::Query
  module QueryInterface
    include Contracts
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport

    Contract PaymentTransaction => Request
    # Create API gateway request from payment transaction data
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for query
    #
    # @return                         [Request]               Request object
    def create_request(payment_transaction)
      raise NotImplementedError
    end

    Contract PaymentTransaction, Response => Response
    # Process API gateway response and update payment transaction
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for update
    # @param    response              [Response]              API gateway response
    #
    # @return                         [Response]              API gateway response
    def process_response(payment_transaction, response)
      raise NotImplementedError
    end
  end
end