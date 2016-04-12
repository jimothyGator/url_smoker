require_relative 'model'

require 'uri'

@sites = []

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
                response_code expected_response_code
            end
            if block_given?
                instance_eval &block
            end
        end

        def content_type(expected)
            @test_case << ContentTypeCondition.new(expected)
        end

        def response_code(expected)
            @test_case << ResponseCodeCondition.new(expected)
        end

    end

    def self.site(name, base_url, &block)
        builder = SiteBuilder.new name, base_url, &block
        builder.site
    end
end

def site(name, base_url, &block)
    site = UrlSmoker::site(name, base_url, &block)
    @sites.push site
    site
end

def smoke
    url_count = @sites.map {|site| site.test_cases.length }.reduce(:+)
    puts "Smoking #{@sites.length} sites and #{url_count} URLs"
    @sites.each do |site|
        UrlSmoker::run_tests site
        puts "--------------"
    end
end