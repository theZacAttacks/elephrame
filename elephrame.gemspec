
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elephrame/version"

Gem::Specification.new do |spec|
  spec.name          = "elephrame"
  spec.version       = Elephrame::VERSION
  spec.authors       = ["Zac"]
  spec.email         = ["thezacattacks@gmail.com"]
  spec.license       = "MIT"

  spec.summary       = %q{A framework for assisting in making mastodon/pleroma bots}
  spec.homepage      = "https://github.com/theZacAttacks/elephrame"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "https://github.com/theZacAttacks/elephrame/releases"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  
  spec.add_dependency 'rufus-scheduler'
  spec.add_dependency 'moostodon', '~> 0.4.0'
  spec.add_dependency 'moo_ebooks'
  spec.add_dependency 'tracery', '~> 0.7'
end
