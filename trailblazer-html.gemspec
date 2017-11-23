
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "trailblazer/html/version"

Gem::Specification.new do |spec|
  spec.name          = "trailblazer-html"
  spec.version       = Trailblazer::Html::VERSION
  spec.authors       = ["Nick Sutterer", "Fran Worley", "Christoph Wagner"]
  spec.email         = ["apotonick@gmail.com", "frances@safetytoolbox.co.uk", "wagner@webit.de"]

  spec.summary       = %q{Generic Html builder code}
  spec.description   = %q{This builder code is extracted from formular and helps to create html tags in your views.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
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

  spec.add_dependency             "declarative",    '~> 0.0.4'
  spec.add_dependency             "uber",           ">= 0.0.11", "< 0.2.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "erbse", "~> 0.1.1"
end
