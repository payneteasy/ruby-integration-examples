require 'test/unit'
require 'paynet_easy_api'
require 'query/query_factory'
require 'query/create_card_ref_query'
require 'query/return_query'

module PaynetEasy::PaynetEasyApi::Query
  class QueryFactoryTest < Test::Unit::TestCase
    def setup
      @object = QueryFactory.new
    end

    def test_query
      query = @object.query 'create-card-ref'
      assert_instance_of CreateCardRefQuery, query

      query = @object.query 'return'
      assert_instance_of ReturnQuery, query
    end
  end
end
