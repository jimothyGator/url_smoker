require_relative 'model'

require 'uri'

module UrlSmoker
    class SiteBuilder
        attr_reader :site

        def initialize(name, base_url, &block)
            @site = Site.new name, base_url
            instance_eval &block
        end

        def get(url, expected_response_code=nil, &block)
            uri = URI.join @site.base_url, url
            builder = TestCaseBuilder.new uri, expected_response_code, &block
            @site << builder.test_case
        end
    end

    class TestCaseBuilder
        attr_reader :test_case

        def initialize(uri, expected_response_code=nil, &block)
            @test_case = TestCase.new uri
            if expected_response_code
                condition = ResponseCodeCondition.new expected_response_code
                @test_case << condition
            end
            if block_given?
                instance_eval &block
            end
        end
    end

    def self.site(name, base_url, &block)
        builder = SiteBuilder.new name, base_url, &block
        builder.site
    end
end

def site(name, base_url, &block)
    UrlSmoker::site(name, base_url, &block)
end