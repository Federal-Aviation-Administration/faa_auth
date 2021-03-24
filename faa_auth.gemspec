# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "faa_auth/version"

Gem::Specification.new do |spec|
  spec.name          = "faa_auth"
  spec.version       = FaaAuth::VERSION
  spec.authors       = ["Dominic Sisneros"]
  spec.email         = ["dsisnero@gmail.com"]

  spec.summary       = %q(Login FAA)
  spec.description   = %q(Login FAA)
  spec.homepage      = "https://faa/faa_auth"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'capybara', '~> 3.3'
  spec.add_runtime_dependency 'capybara-sessionkeeper', "~> 0.1"
  spec.add_runtime_dependency 'selenium-webdriver', '~> 3.14'
  spec.add_runtime_dependency 'cuprite', '~> 0.1'
  spec.add_runtime_dependency 'highline', '~> 2.0'
  spec.add_runtime_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "byebug"

end
