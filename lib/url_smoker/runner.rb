module UrlSmoker
  def self.run_tests(site)
    puts "Testing #{site.name} (#{site.base_url})"
    site.each do |test_case|
      response = Net::HTTP.get_response test_case.uri
      results = test_case.eval response

      success = results.all? {|success, _| success}
      puts "FAIL".red + ": #{test_case.uri}" unless success
      puts "PASS".green + ": #{test_case.uri}" if success

      if !success
        failed_results = results.select {|success, _| !success }
        failed_results.each do |success, condition|
          puts "      #{condition}".red
        end
      end

    end
  end
end