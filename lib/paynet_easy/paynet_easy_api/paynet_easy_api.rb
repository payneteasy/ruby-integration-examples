module PaynetEasy
  module PaynetEasyApi
    module PaymentData
    end
    module Callback
    end
    module Query
      module Prototype
      end
    end
    module Transport
    end
    module Util
    end
  end
end

require 'payment_processor'
require 'payment_data/query_config'
require 'payment_data/payment_transaction'
require 'payment_data/payment'
require 'payment_data/billing_address'
require 'payment_data/customer'
require 'payment_data/credit_card'
require 'payment_data/recurrent_card'
require 'transport/callback_response'