require 'test/unit'
require 'paynet_easy_api'
require 'utils/property_accessor'

module PaynetEasy::PaynetEasyApi::Utils
  class PropertyAccessorTest < Test::Unit::TestCase

    def test_get_value
      [
          ['test_property',               'test', true],
          ['test_object.test_property',   'test', true],
          ['test_property.test_property',  nil,   false],
          ['unknown_property',             nil,   false]
      ]
      .each do |property_path, expected_value, fail_on_error|
        actual_value = PropertyAccessor.get_value TestObject.new, property_path, fail_on_error
        assert_equal expected_value, actual_value
      end
    end

    def test_set_value
      [
          ['test_property',               'test', true],
          ['test_object.test_property',   'test', true],
          ['test_property.test_property',  nil,   false],
          ['unknown_property',             nil,   false]
      ]
      .each do |property_path, expected_value, fail_on_error|
        test_object = TestObject.new

        PropertyAccessor.set_value test_object, property_path, expected_value, fail_on_error
        actual_value = PropertyAccessor.get_value test_object, property_path, fail_on_error

        assert_equal expected_value, actual_value
      end
    end
  end

  class TestObject
    attr_accessor :test_property
    attr_accessor :test_object
    attr_accessor :empty_property

    def initialize
      self.test_property = 'test'
    end

    def test_object
      @test_object ||= TestObject.new
    end
  end
end