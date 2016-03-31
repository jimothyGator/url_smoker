require_relative 'colorize'

require 'forwardable'
require 'net/http'

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

    def run_tests
      @test_cases.each do |test_case|
        test_case.run
      end
    end
  end


  class TestCase
    include Enumerable
    extend Forwardable
    def_delegators :@conditions, :each, :<<, :include?, :empty?

    def initialize(uri)
      @uri = uri
      @conditions = []
    end

    def run
      response = Net::HTTP.get_response @uri
      @conditions.each do |condition|
        success, message = condition.eval(response)
        puts " FAIL:".red + " #{@uri}, #{message}" unless success
        puts " PASS:".green + " #{@uri}" if success
      end
    end
  end

  class ResponseCodeCondition
    def initialize(expected)
      @expected = expected
    end

    def eval(response) 
      if @expected.to_s == response.code
        [true, ""]
      else
        [false, "expected: #{@expected}, received #{response.code}"]
      end
    end
  end

  class ContentTypeCondition
    def initialize(expected)
      @expected = expected
    end

    def eval(response) 
      if @expected == response.content_type
        [true, ""]
      else
        [false, "expected: #{@expected}, received #{response.content_type}"]
      end
    end
  end
end