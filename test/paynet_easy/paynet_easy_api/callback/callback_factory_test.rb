require 'test/unit'
require 'paynet_easy_api'
require 'callback/callback_factory'
require 'callback/customer_return_callback'
require 'callback/paynet_easy_callback'

module PaynetEasy::PaynetEasyApi::Callback
  class CallbackFactoryTest < Test::Unit::TestCase
    def setup
      @object = CallbackFactory.new
    end

    def test_callback
      callback = @object.callback 'customer_return'
      assert_instance_of CustomerReturnCallback, callback

      callback = @object.callback 'sale'
      assert_instance_of PaynetEasyCallback, callback
      assert_equal 'sale', callback.instance_variable_get(:@callback_type)
    end
  end
end