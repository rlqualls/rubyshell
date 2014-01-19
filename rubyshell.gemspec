require "date"

Gem::Specification.new do |s|
  s.name = "rubyshell"
  s.version = "0.0.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Robert Qualls", "Adam Wiggins"]
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
  s.add_development_dependency("rspec", ["~> 1.2.0"])
end

