require_relative 'model'

require 'uri'

@sites = []

module UrlSmoker
    module DSL
        class SiteBuilder
            def initialize(name, base_url, &block)
                @site = Site.new name, base_url
                instance_eval &block
            end

            def get(url, expected_response_code=nil, &block)
                builder = TestCaseBuilder.new @site, url, expected_response_code, &block
                @site << builder.build
            end

            def build
                @site
            end
        end

        class TestCaseBuilder
            def initialize(site, uri, expected_response_code=nil, &block)
                @test_case = TestCase.new site, uri
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

            def build
                @test_case
            end

        end

        def self.site(name, base_url, &block)
            builder = SiteBuilder.new name, base_url, &block
            site = builder.build
            if defined? @sites
                @sites << site
            end

            site
        end

        def self.load(filename)
            @sites ||= []
            result = self.instance_eval(File.read(filename), filename)

            @sites
        end
    end
end


