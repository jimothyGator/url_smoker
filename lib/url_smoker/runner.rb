module UrlSmoker
  PASS = "\u2714"
  FAIL = "\u2718"

  def self.run_tests(site)
    puts "Testing #{site.name} (#{site.base_url})"
    site.each do |test_case|
      response = Net::HTTP.get_response test_case.uri
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
end