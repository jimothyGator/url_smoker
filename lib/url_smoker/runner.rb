require 'uri'
require 'net/http'
require 'net/http/digest_auth'

module UrlSmoker
  PASS = "\u2714"
  FAIL = "\u2718"
  DIGEST_AUTH = Net::HTTP::DigestAuth.new

  def self.run_tests(site)
    puts "Testing #{site.name} (#{site.base_url})"
    base_uri = URI(site.base_url)
    Net::HTTP.start(base_uri.host, base_uri.port, use_ssl: (base_uri.scheme == 'https')) do |http|
      site.each do |test_case|
        run_test(site, test_case, http)
      end
    end
  end

  private
  def self.run_test(site, test_case, http)
    uri = test_case.uri.dup
    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth(test_case.auth.user, test_case.auth.password) if test_case.basic_auth?
    
    if test_case.digest_auth?
      uri.user = test_case.auth.user
      uri.password = test_case.auth.password
      response = http.request request
      auth = DIGEST_AUTH.auth_header uri, response['www-authenticate'], 'GET'
      request = Net::HTTP::Get.new uri
      request.add_field 'Authorization', auth
    end

    response = http.request request
    results = test_case.eval response

    success = results.all? {|success, _| success}
    puts "  #{FAIL} #{test_case.uri}".red unless success
    puts "  #{PASS} #{test_case.uri}".green if success

    if !success
      failed_results = results.select {|success, _| !success }
      failed_results.each do |success, condition|
        puts "      #{condition}".red
      end
    end
  end
end