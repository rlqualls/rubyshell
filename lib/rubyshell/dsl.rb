# The RubyShell module has some convenience methods for accessing the
# local box.
module RubyShell
  # Access the root filesystem of the local box.  Example:
  #
  #   RubyShell['/etc/hosts'].contents
  #
  def self.[](key)
    box[key]
  end

  # Create a dir object from the path of a provided file.  Example:
  #
  #   RubyShell.dir(__FILE__).files
  #
  def self.dir(filename)
    box[::File.expand_path(::File.dirname(filename)) + '/']
  end

  # Create a dir object based on the shell's current working directory at the
  # time the program was run.  Example:
  #
  #   RubyShell.launch_dir.files
  #
  def self.launch_dir
    box[::Dir.pwd + '/']
  end

  # Run a bash command in the root of the local machine.  Equivalent to
  # RubyShell::Box.new.bash.
  def self.bash(command, options={})
    box.bash(command, options)
  end

  # Pull the process list for the local machine.  Example:
  #
  #   RubyShell.processes.filter(:cmdline => /ruby/)
  #
  def self.processes
    box.processes
  end

  # Get the process object for this program's PID.  Example:
  #
  #   puts "I'm using #{RubyShell.my_process.mem} blocks of memory"
  #
  def self.my_process
    box.processes.filter(:pid => ::Process.pid).first
  end

  # Create a box object for localhost.
  def self.box
    @box ||= RubyShell::Box.new
  end

  # Quote a path for use in backticks, say.
  def self.quote(path)
    path.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
  end
end
