require 'rake'

######################################################

task :test do
  system("rspec")
end
#
# desc "Print specdocs"
# RSpec::Core::RakeTask.new(:doc) do |t|
# 	t.spec_opts = ["--format", "specdoc", "--dry-run"]
# 	t.spec_files = FileList['spec/*_spec.rb']
# end

# desc "Run all examples with simplecov"
# Spec::Rake::SpecTask.new('simplecov') do |t|
# 	t.spec_files = FileList['spec/*_spec.rb']
# 	t.simplecov = true
# 	t.simplecov_opts = ['--exclude', 'examples']
# end

task :default => :test

######################################################

require 'rdoc/task'

Rake::RDocTask.new do |t|
	t.rdoc_dir = 'rdoc'
	t.title    = "rubyshell, a Ruby replacement for bash+ssh"
	t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
	t.options << '--charset' << 'utf-8'
	t.rdoc_files.include('lib/rubyshell.rb')
	t.rdoc_files.include('lib/rubyshell/*.rb')
end

