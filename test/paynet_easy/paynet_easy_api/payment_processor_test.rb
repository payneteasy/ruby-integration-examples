require 'test/unit'
require 'paynet_easy_api'
require 'payment_processor'
require 'payment_data/payment_transaction'
require 'payment_data/payment'
require 'payment_data/customer'
require 'payment_data/billing_address'
require 'payment_data/query_config'
require 'transport/response'
require 'transport/callback_response'
require_relative './fake'

module PaynetEasy::PaynetEasyApi
  class PaymentProcessorTest < Test::Unit::TestCase
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Transport
    include PaynetEasy::PaynetEasyApi::Query
    include PaynetEasy::PaynetEasyApi::Callback
    include PaynetEasy::PaynetEasyApi::Fake

    def setup
      @object                 = PaymentProcessor.new
      @fake_query_factory     = FakeQueryFactory.new
      @fake_callback_factory  = FakeCallbackFactory.new
      @fake_gateway_client    = FakeGatewayClient.new
    end

    def test_execute_query
      [
        [
          'status',
          {
            'status'            => 'approved',
            'type'              => 'status-response',
            'paynet-order-id'   => '_',
            'merchant-order-id' => '_',
            'serial-number'     => '_'
          },
          PaymentProcessor::HANDLER_FINISH_PROCESSING
        ],
        [
          'sale-form',
          {
            'redirect-url'      => 'http://example.com',
            'type'              => 'async-form-response',
            'paynet-order-id'   => '_',
            'merchant-order-id' => '_',
            'serial-number'     => '_'
          },
          PaymentProcessor::HANDLER_REDIRECT
        ],
        [
          'status',
          {
            'html'              => '<html></html>',
            'type'              => 'status-response',
            'paynet-order-id'   => '_',
            'merchant-order-id' => '_',
            'serial-number'     => '_'
          },
          PaymentProcessor::HANDLER_SHOW_HTML
        ],
        [
          'status',
          {
            'status'            => 'processing',
            'type'              => 'status-response',
            'paynet-order-id'   => '_',
            'merchant-order-id' => '_',
            'serial-number'     => '_'
          },
          PaymentProcessor::HANDLER_STATUS_UPDATE
        ]
      ].each do |query_name, response_data, handler_name|
        assert_execute_query query_name, response_data, handler_name
      end
    end

    def assert_execute_query(query_name, response_data, handler_name)
      handler_called = false
      handler = ->(*args){handler_called = true}

      @fake_gateway_client.response = Response.new response_data
      @object.gateway_client = @fake_gateway_client
      @object.set_handler handler_name, &handler

      assert_not_nil @object.execute_query(query_name, payment_transaction)
      assert_true handler_called, "For query #{query_name} and handler #{handler_name}"
    end

    def test_execute_query_without_exception_handler
      assert_raise_kind_of Exception do
        @object.execute_query 'sale', PaymentTransaction.new
      end
    end

    def test_execute_query_with_exception_on_create_request
      handler_called = false
      handler = ->(*args){handler_called = true}

      @object.set_handler PaymentProcessor::HANDLER_CATCH_EXCEPTION, &handler
      @object.execute_query 'sale', PaymentTransaction.new

      assert_true handler_called
    end

    def test_execute_query_with_exception_on_process_response
      handler_called = false
      handler = ->(*args){handler_called = true}

      exception_query               = ExceptionQuery.new 'exception'
      exception_query.request       = Request.new
      @fake_query_factory.query     = exception_query
      @fake_gateway_client.response = Response.new

      @object.gateway_client = @fake_gateway_client
      @object.query_factory  = @fake_query_factory
      @object.set_handler PaymentProcessor::HANDLER_CATCH_EXCEPTION, &handler

      @object.execute_query 'exception', PaymentTransaction.new

      assert_true handler_called
    end

    def test_process_customer_return
      callback_response = CallbackResponse.new(
      {
        'status'            => 'approved',
        'orderid'           => '_',
        'merchant_order'    => '_',
        'client_orderid'    => '_',
        'control'           => '2c84ae87d73fa3dc116b3203e8bb1c133eed829d'
      })

      payment_transaction = payment_transaction()
      payment_transaction.status = PaymentTransaction::STATUS_PROCESSING

      handler_called = false
      handler = ->(*args){handler_called = true}

      @object.set_handler PaymentProcessor::HANDLER_FINISH_PROCESSING, &handler

      assert_not_nil @object.process_customer_return callback_response, payment_transaction
      assert_true handler_called
    end

    def test_process_paynet_easy_callback
      handler_called = false
      handler = ->(*args){handler_called = true}

      @fake_callback_factory.callback = FakeCallback.new 'fake'
      @object.callback_factory        = @fake_callback_factory
      @object.set_handler PaymentProcessor::HANDLER_FINISH_PROCESSING, &handler

      assert_not_nil @object.process_paynet_easy_callback CallbackResponse.new({'type' => 'fake'}), payment_transaction
      assert_true handler_called
    end

    def test_process_callback_on_finished_payment
      handler_called = false
      handler = ->(*args){handler_called = true}

      @fake_callback_factory.callback = FakeCallback.new 'fake'
      @object.callback_factory        = @fake_callback_factory
      @object.set_handler PaymentProcessor::HANDLER_FINISH_PROCESSING, &handler

      @object.process_paynet_easy_callback CallbackResponse.new({'type' => 'fake'}), payment_transaction
      assert_true handler_called
    end

    def test_process_paynet_easy_callback_with_exception
      handler_called = false
      handler = ->(*args){handler_called = true}

      @object.set_handler PaymentProcessor::HANDLER_CATCH_EXCEPTION, &handler
      @object.process_paynet_easy_callback CallbackResponse.new({'type' => 'sale'}), PaymentTransaction.new

      assert_true handler_called
    end

    def test_handlers
      @object.set_handlers(
      {
        PaymentProcessor::HANDLER_SAVE_CHANGES  => ->(*args){},
        PaymentProcessor::HANDLER_SHOW_HTML     => ->(*args){}
      })

      assert_equal 2, @object.instance_variable_get(:@handlers).length
      assert_true @object.send(:has_handler?, PaymentProcessor::HANDLER_SAVE_CHANGES)
      assert_true @object.send(:has_handler?, PaymentProcessor::HANDLER_SHOW_HTML)

      @object.remove_handler PaymentProcessor::HANDLER_SAVE_CHANGES

      assert_equal 1, @object.instance_variable_get(:@handlers).length
      assert_false @object.send(:has_handler?, PaymentProcessor::HANDLER_SAVE_CHANGES)
      assert_true @object.send(:has_handler?, PaymentProcessor::HANDLER_SHOW_HTML)

      @object.remove_handlers

      assert_empty @object.instance_variable_get(:@handlers)
    end

    def test_call_handler
      handler_called = false
      handler = ->(*args){handler_called = true}

      @object.set_handler PaymentProcessor::HANDLER_SAVE_CHANGES, &handler
      @object.send :call_handler, PaymentProcessor::HANDLER_SAVE_CHANGES, PaymentTransaction.new, Response.new

      assert_true handler_called
    end

    protected

    # @return   [PaymentTransaction]
    def payment_transaction
      PaymentTransaction.new(
      {
        'payment'             =>  Payment.new(
        {
          'client_id'             => '_',
          'paynet_id'             => '_',
          'description'           => 'This is test payment',
          'amount'                =>  99.1,
          'currency'              => 'USD',
          'customer'              =>  Customer.new(
          {
            'first_name'            => 'Vasya',
            'last_name'             => 'Pupkin',
            'email'                 => 'vass.pupkin@example.com',
            'ip_address'            => '127.0.0.1',
            'birthday'              => '112681'
          }),
          'billing_address'       =>  BillingAddress.new(
          {
            'country'               => 'US',
            'state'                 => 'TX',
            'city'                  => 'Houston',
            'first_line'            => '2704 Colonial Drive',
            'zip_code'              => '1235',
            'phone'                 => '660-485-6353',
            'cell_phone'            => '660-485-6353'
          })
        }),
        'query_config'      => QueryConfig.new(
        {
          'login'               => '_',
          'redirect_url'        => 'http://example.com',
          'gateway_url_sandbox' => 'http://example.com/sandbox',
          'signing_key'         => 'key'
        })
      });
    end
  end
end
