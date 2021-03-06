require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'rspec'
require 'rubyshell'
require 'rubyshell/dsl'


def mock_config(&block)
  mock_config_start
  block.call(config)
  mock_config_end
end

def mock_config_sandbox_dir
  "/tmp/fake_config.#{Process.pid}"
end

def mock_config_start
  mock_config_cleanup
  RubyShell::Config.new(mock_config_sandbox_dir)
end

def mock_config_cleanup
  FileUtils.rm_rf(mock_config_sandbox_dir)
end
