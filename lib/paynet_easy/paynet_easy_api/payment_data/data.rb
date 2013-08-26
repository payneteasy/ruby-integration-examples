require 'contracts'
require 'util/property_accessor'

module PaynetEasy::PaynetEasyApi::PaymentData
  class Data
    include Contracts
    include PaynetEasy::PaynetEasyApi::Util

    def initialize(data_hash = {}, fail_on_unknown_field = true)
      data_hash.each do |property_path, value|
        PropertyAccessor.set_value self, property_path, value, fail_on_unknown_field
      end
    end
  end
end