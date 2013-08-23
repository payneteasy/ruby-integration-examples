require 'test/unit'
require 'paynet_easy_api'
require 'transport/response'

module PaynetEasy::PaynetEasyApi::Transport
  class ResponseTest < Test::Unit::TestCase

    def setup
      @object = Response.new
    end

    def test_error?
      @object.replace 'type' => 'validation-error'
      assert_true @object.error?

      @object.replace 'type' => 'error'
      assert_true @object.error?

      @object.replace 'type' => 'async-response', 'status' => 'error'
      assert_true @object.error?

      @object.replace 'type' => 'async-response', 'status' => 'approved'
      assert_false @object.error?
    end
  end
end