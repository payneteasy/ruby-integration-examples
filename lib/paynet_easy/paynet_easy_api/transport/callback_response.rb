require 'transport/response'

module PaynetEasy::PaynetEasyApi::Transport
  class CallbackResponse < Response
    def amount
      fetch 'amount', nil
    end

    def comment
      fetch 'comment', nil
    end

    def merchant_data
      fetch 'merchant_data', nil
    end
  end
end