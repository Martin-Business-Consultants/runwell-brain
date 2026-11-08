require_relative "lib/brain/version"

# The gemspec's name is the plugin's key and its table prefix.
Gem::Specification.new do |spec|
  spec.name = "brain"
  spec.version = Brain::VERSION
  spec.summary = "A Runwell plugin: what everyone should know about each client and piece of work"
  spec.authors = [ "Martin Business Consultants" ]
  spec.homepage = "https://github.com/Martin-Business-Consultants/runwell-brain"
  spec.license = "FSL-1.1-MIT"
  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.required_ruby_version = ">= 3.3"
  spec.add_dependency "rails", ">= 8.1"
end
