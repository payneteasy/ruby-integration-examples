require 'util/string'
require 'callback/callback_prototype'

module PaynetEasy::PaynetEasyApi::Callback
  class CallbackFactory
    @@allowed_payneteasy_callback_types =
    [
      'sale',
      'revers al',
      'chargeback'
    ]

    # Get callback processor by callback type
    #
    # @param    callback_type   [String]              Callback type
    #
    # @return                   [CallbackPrototype]   Callback processor
    def callback(callback_type)
      callback_class = "#{callback_type.camelize}Callback"
      callback_file  = "callback/#{callback_type}_callback"

      begin
        instantiate_callback callback_file, callback_class, callback_type
      rescue LoadError => error
        if @@allowed_payneteasy_callback_types.include? callback_type
          instantiate_callback 'callback/paynet_easy_callback', 'PaynetEasyCallback', callback_type
        else
          raise error
        end
      end
    end

    protected

    # Load callback class file and return new callback object
    #
    # @param    callback_file     [String]              Callback class file
    # @param    callback_class    [String]              Callback class
    # @param    callback_type     [String]              Callback type
    #
    # @return                     [CallbackPrototype]   Callback object
    def instantiate_callback(callback_file, callback_class, callback_type)
      require callback_file
      PaynetEasy::PaynetEasyApi::Callback.const_get(callback_class).new(callback_type)
    end
  end
end