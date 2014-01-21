module RubyShell
  module Helpers
    # Determine if executable exists for cmd, taken from:
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def self.which(cmd)
      cmd = cmd.split(' ').first
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(::File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = ::File.join(path, "#{cmd}#{ext}")
          return exe if ::File.executable? exe
        }
      end
      return nil
    end
  end
end
