require_relative 'colorize'

require 'forwardable'

module UrlSmoker
  class Site
    include Enumerable
    extend Forwardable
    attr_reader :base_url, :test_cases, :name

    def_delegators :@test_cases, :each, :<<, :include?, :empty?

    def initialize(name, base_url)
      @name = name
      @base_url = base_url
      @test_cases = []
    end
  end


  class TestCase
    include Enumerable
    extend Forwardable
    attr_reader :uri
    def_delegators :@conditions, :each, :<<, :include?, :empty?

    def initialize(uri)
      @uri = uri
      @conditions = []
    end

    def eval(response)
      results = []

      @conditions.each do |condition|
        success = condition.eval(response)
        results << [success, condition]
        break unless success
      end

      results
    end
  end

  module Condition
    attr_reader :actual, :expected, :success

    def condition_name
      self.class.name.split("::").last
    end

    def to_s
      if success
        "#{condition_name}: #{expected}"
      else
        "#{condition_name}: Expected #{expected}, actual #{actual}"
      end     
    end   
  end

  class ResponseCodeCondition
    include Condition

    def initialize(expected)
      @expected = expected
    end

    def eval(response)
      @actual = response.code
      @success = @expected.to_s == response.code

      @success
    end

    def condition_name
      "Response code"
    end

  end

  class ContentTypeCondition
    include Condition

    def initialize(expected)
      @expected = expected
    end

    def eval(response) 
      @actual = response.content_type
      @success = @expected == @actual

      @success
    end


    def condition_name
      "Content type"
    end

  end
end