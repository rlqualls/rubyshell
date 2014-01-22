lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rubyshell/version"
require "date"

Gem::Specification.new do |s|
  s.name = "rubyshell"
  s.version = RubyShell::VERSION
  s.required_rubygems_version = "1.3.5" 
  s.authors = ["Robert Qualls"]
  s.date = Date.today.to_s
  s.description = %q{A Ruby replacement for bash+ssh, providing both an interactive shell and a library.  Manage both local and remote unix systems from a single client.}
  s.email = "robert@robertqualls.com"
  s.executables = ["rubyshell"]
  s.files = Dir["lib/**/**"]
  s.homepage = "http://github.com/rlqualls/rubyshell"
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A Ruby replacement for bash+ssh.}
  s.test_files = Dir["spec/**/**"]

  s.add_development_dependency("rake", [">= 0.9.0"])
  s.add_development_dependency("rspec", ["~> 2.14.0"])
  s.add_development_dependency("simplecov")
end

