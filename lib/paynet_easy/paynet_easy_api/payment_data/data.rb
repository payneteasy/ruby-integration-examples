require 'contracts'
require 'utils/property_accessor'

module PaynetEasy::PaynetEasyApi::PaymentData
  class Data
    include Contracts
    include Utils

    Contract Hash, Bool => None
    # Initialize object from input array.
    #
    # @param    data_hash                 [Hash]                    Hash with initial object data
    # @param    fail_on_unknown_field     [TrueClass|FalseClass]    If true, exception will be raised
    #                                                               if the setter is not found
    def initialize(data_hash = {}, fail_on_unknown_field = true)
      data_hash.each_pair do |property_path, value|
        PropertyAccessor.set_value self, property_path, value, fail_on_unknown_field
      end
    end
  end
end