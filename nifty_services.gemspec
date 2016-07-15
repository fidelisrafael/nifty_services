# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nifty_services/version'

Gem::Specification.new do |spec|
  spec.name          = "nifty_services"
  spec.version       = NiftyServices::VERSION
  spec.authors       = ["Rafael Fidelis"]
  spec.email         = ["rafa_fidelis@yahoo.com.br"]

  spec.summary       = %q{Nifty and awesome service oriented architecture library for Ruby applications.}
  spec.description   = %q{The killing simple services object oriented layer for Ruby (and Rails) applications to give robustness and cohesion back to your code.}
  spec.homepage      = "https:/github.com/fidelisrafael/nifty_services"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '~> 4.2.2'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
