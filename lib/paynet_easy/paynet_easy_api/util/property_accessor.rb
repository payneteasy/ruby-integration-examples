require 'contracts'

module PaynetEasy::PaynetEasyApi::Util
  module PropertyAccessor
    include Contracts

    Contract Any, String, Bool => Any
    # Get property value by property path.
    #
    # @param    object          [Object]                  Object with data
    # @param    property_path   [String]                  Path to property
    # @param    fail_on_error   [TrueClass|FalseClass]    Throw exception if error occurred or not
    #
    # @return                   [Object|NilClass]
    def self.get_value(object, property_path, fail_on_error = true)
      if !property_path.include? '.'
        if object.respond_to? property_path
          return object.send property_path
        elsif fail_on_error
          raise RuntimeError, "Expected object with method '#{property_path}'"
        else
          return
        end
      end

      first_property, path_rest = property_path.split '.', 2
      first_object = object.send first_property

      if first_object
        return self.get_value first_object, path_rest, fail_on_error
      elsif fail_on_error
        raise RuntimeError, "Object expected for property path '#{first_property}'"
      end
    end

    Contract Any, String, Any, Bool => Any
    # Set property value by property path.
    #
    # @param    object            [Object]                  Object with data
    # @param    property_path     [String]                  Path to property
    # @param    value             [Object]                  Value to set
    # @param    fail_on_error     [TrueClass|FalseClass]    Throw exception if error occurred or not
    #
    # @return                     [Object|NilClass]
    def self.set_value(object, property_path, value, fail_on_error = true)
      if !property_path.include? '.'
        if object.respond_to? "#{property_path}="
          return object.send "#{property_path}=", value
        elsif fail_on_error
          raise RuntimeError, "Expected object with method '#{property_path}='"
        else
          return
        end
      end

      first_property, path_rest = property_path.split '.', 2
      first_object = object.send(first_property)

      if first_object
        return self.set_value first_object, path_rest, value, fail_on_error
      elsif fail_on_error
        raise RuntimeError, "Object expected for property path '#{first_property}'"
      end
    end
  end
end