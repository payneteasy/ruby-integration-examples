require 'paynet_easy_api'
require 'payment_data/payment_transaction'
require 'query/query_factory'
require 'query/prototype/query'
require 'transport/gateway_client'
require 'callback/callback_prototype'
require 'callback/callback_factory'

module PaynetEasy::PaynetEasyApi
  module Fake
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Query
    include PaynetEasy::PaynetEasyApi::Callback

    class FakeQueryFactory < QueryFactory
      attr_writer :query

      def query(api_query_name)
        @query
      end
    end

    class FakeGatewayClient < GatewayClient
      attr_accessor :request
      attr_accessor :response

      def make_request(request)
        self.request = request
        response()
      end
    end

    class FakeCallbackFactory < CallbackFactory
      attr_writer :callback

      def callback(callback_type)
        @callback
      end
    end

    class FakeQuery < Prototype::Query
      attr_accessor :request

      def create_request(payment_transaction)
        request()
      end

      def process_response(payment_transaction, response)
        if response.approved?
          payment_transaction.status = PaymentTransaction::STATUS_APPROVED
        end

        response
      end
    end

    class ExceptionQuery < FakeQuery
      def process_response(payment_transaction, response)
        raise RuntimeError, 'Process response error'
      end
    end

    class FakeCallback < CallbackPrototype
      def process_callback(payment_transaction, callback_response)
        payment_transaction.status = PaymentTransaction::STATUS_APPROVED
        callback_response
      end
    end
  end
end