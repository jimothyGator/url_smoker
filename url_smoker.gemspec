# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'url_smoker/version'

Gem::Specification.new do |spec|
  spec.name          = "url_smoker"
  spec.version       = UrlSmoker::VERSION
  spec.authors       = ["Jim Cushing"]
  spec.email         = ["jimothy@mac.com"]

  spec.summary       = "Smoke test web sites"
  spec.description   = "Run simple smoke tests against a collection of URLs"
  spec.homepage      = "https://github.com/jimothyGator/url_smoker"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "tilt-handlebars", "~> 1.4"
  # spec.add_dependency "erubis", "~> 2.7"
  # spec.add_dependency 'sass'
  # spec.add_dependency 'bourbon'
  # spec.add_dependency 'neat'
  # spec.add_dependency 'bitters'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"

end
