require 'response'

module PaynetEasy::PaynetEasyApi::Transport
  class CallbackResponse < Response
    attr_reader :amount
    attr_reader :comment
    attr_reader :merchant_data
    attr_reader :type
  end
end