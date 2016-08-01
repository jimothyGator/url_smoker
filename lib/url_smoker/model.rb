require_relative 'colorize'
require 'uri'
require 'ostruct'

require 'forwardable'

module UrlSmoker
  class Site
    include Enumerable
    extend Forwardable
    attr_reader :base_url, :test_cases, :name, :auth

    def_delegators :@test_cases, :each, :<<, :include?, :empty?

    def initialize(name, base_url)
      @name = name
      @base_url = base_url
      @test_cases = []
    end

    def basic_auth(user, password)
      @auth = OpenStruct.new({type: :basic, user: user, password: password})
    end

    def digest_auth(user, password)
      @auth = OpenStruct.new({type: :digest, user: user, password: password})
    end


  end


  class TestCase
    include Enumerable
    extend Forwardable
    attr_reader :uri, :auth
    def_delegators :@conditions, :each, :<<, :include?, :empty?

    def initialize(site, uri, user = nil, password = nil)
      @site, @uri = site, uri
      @auth = site.auth
      @conditions = []
    end

    def uri
      URI.join(@site.base_url, @uri).freeze
    end

    def basic_auth(user, password)
      @auth = OpenStruct.new({type: :basic, user: user, password: password})
    end

    def digest_auth(user, password)
      @auth = OpenStruct.new({type: :digest, user: user, password: password})
    end 

    def basic_auth?
      return @auth && @auth.type == :basic
    end

    def digest_auth?
      return @auth && @auth.type == :digest
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