require 'readline'
require 'rubyshell/helpers'

# RubyShell::Shell is used to create an interactive shell.  It is invoked by the rubyshell binary.
module RubyShell
	class Shell
		attr_accessor :suppress_output
		# Set up the user's environment, including a pure binding into which
		# env.rb and commands.rb are mixed.
		def initialize
			root = RubyShell::Dir.new('/')
			home = RubyShell::Dir.new(ENV['HOME']) if ENV['HOME']
			pwd = RubyShell::Dir.new(ENV['PWD']) if ENV['PWD']

			@config = RubyShell::Config.new

			@config.load_history.each do |item|
				Readline::HISTORY.push(item)
			end

			Readline.basic_word_break_characters = ""
			Readline.completion_append_character = nil
			Readline.completion_proc = completion_proc

			@box = RubyShell::Box.new
			@pure_binding = @box.instance_eval "binding"
			$last_res = nil

			eval @config.load_env, @pure_binding

			commands = @config.load_commands
			RubyShell::Dir.class_eval commands
			Array.class_eval commands
		end

		# Run a single command.
		def execute(cmd)
			res = eval(cmd, @pure_binding)
			$last_res = res
			eval("_ = $last_res", @pure_binding)
			print_result res
		rescue RubyShell::Exception => e
        puts "Exception #{e.class} -> #{e.message}"
		rescue ::Exception => e
      # If not valid Ruby code, try to run it as an executable
      if Helpers.which(cmd)
        # args = cmd.split(' ')
        puts `#{cmd}`
        # system(*args)
      else
        puts "Exception #{e.class} -> #{e.message}"
        e.backtrace.each do |t|
          puts "   #{::File.expand_path(t)}"
        end
      end
		end

		# Run the interactive shell using readline.
    # Read multiple lines if it looks like mutliline code
		def run
      @ends_needed = 0
			loop do
        cmd = Readline.readline('rubyshell> ')
        check_multiline(cmd)
				# cmd = Readline.readline('rubyshell> ')
        # if cmd =~ /do/ or cmd =~ /^def/ or cmd =~ /^class/ or cmd =~ /^module/
        #   @ends_needed = 1
        #   cmd << ';' << Readline.readline('rubyshell>> ')
        #   if cmd =~ /end$/
        #     @ends_needed -= 1
        #     if @ends_needed > 0
        #       cmd << ';' << Readline.readline('rubyshell>> ')
        #     end
        #   else

        #   end
        # end

				finish if cmd.nil? or cmd == 'exit'
				next if cmd == ""
				Readline::HISTORY.push(cmd)

				execute(cmd)
			end
		end
    
    # Add additional lines to the command string if it looks like multiline Ruby
    # Currently the @ends_needed logic is off-by-1:
    #   (should be > 0 not > 1) but works that way.
    def check_multiline(cmd)
      if cmd =~ /if/ or cmd =~/do/ or cmd =~ /^def/ or cmd =~ /^class/ or cmd =~ /^module/
        @ends_needed += 1
        cmd << ';' << Readline.readline('rubyshell>> ')
        if cmd =~ /end$/
          @ends_needed -= 1
          if @ends_needed > 1
            cmd << ';' << Readline.readline('rubyshell>> ')
          end
        else
          check_multiline(cmd)
        end
      end
    end
    private :check_multiline

		# Save history to ~/.rubyshell/history when the shell exists.
		def finish
			@config.save_history(Readline::HISTORY.to_a)
			puts
			exit
		end

		# Nice printing of different return types, particularly RubyShell::SearchResults.
		def print_result(res)
			return if self.suppress_output
			if res.kind_of? String
				puts res
			elsif res.kind_of? RubyShell::SearchResults
				widest = res.entries.map { |k| k.full_path.length }.max
				res.entries_with_lines.each do |entry, lines|
					print entry.full_path
					print ' ' * (widest - entry.full_path.length + 2)
					print "=> "
					print res.colorize(lines.first.strip.head(30))
					print "..." if lines.first.strip.length > 30
					if lines.size > 1
						print " (plus #{lines.size - 1} more matches)"
					end
					print "\n"
				end
				puts "#{res.entries.size} matching files with #{res.lines.size} matching lines"
			elsif res.respond_to? :each
				counts = {}
				res.each do |item|
					puts item
					counts[item.class] ||= 0
					counts[item.class] += 1
				end
				if counts == {}
					puts "=> (empty set)"
				else
					count_s = counts.map do |klass, count|
						"#{count} x #{klass}"
					end.join(', ')
					puts "=> #{count_s}"
				end
			else
				puts "=> #{res.inspect}"
			end
		end

		def path_parts(input)		# :nodoc:
			case input
			when /((?:@{1,2}|\$|)\w+(?:\[[^\]]+\])*)([\[\/])(['"])([^\3]*)$/
				$~.to_a.slice(1, 4).push($~.pre_match)
			when /((?:@{1,2}|\$|)\w+(?:\[[^\]]+\])*)(\.)(\w*)$/
				$~.to_a.slice(1, 3).push($~.pre_match)
			when /((?:@{1,2}|\$|)\w+)$/
				$~.to_a.slice(1, 1).push(nil).push($~.pre_match)
			else
				[ nil, nil, nil ]
			end
		end

		def complete_method(receiver, dot, partial_name, pre)
			path = eval("#{receiver}.full_path", @pure_binding) rescue nil
			box = eval("#{receiver}.box", @pure_binding) rescue nil
			if path and box
				(box[path].methods - Object.methods).select do |e|
					e.match(/^#{Regexp.escape(partial_name)}/)
				end.map do |e|
					(pre || '') + receiver + dot + e
				end
			end
		end

		def complete_path(possible_var, accessor, quote, partial_path, pre)		# :nodoc:
			original_var, fixed_path = possible_var, ''
			if /^(.+\/)([^\/]*)$/ === partial_path
				fixed_path, partial_path = $~.captures
				possible_var += "['#{fixed_path}']"
			end
			full_path = eval("#{possible_var}.full_path", @pure_binding) rescue nil
			box = eval("#{possible_var}.box", @pure_binding) rescue nil
			if full_path and box
				RubyShell::Dir.new(full_path, box).entries.select do |e|
					e.name.match(/^#{Regexp.escape(partial_path)}/)
				end.map do |e|
					(pre || '') + original_var + accessor + quote + fixed_path + e.name + (e.dir? ? "/" : "")
				end
			end
		end

		def complete_variable(partial_name, pre)
			lvars = eval('local_variables', @pure_binding)
			gvars = eval('global_variables', @pure_binding)
			ivars = eval('instance_variables', @pure_binding)
			(lvars + gvars + ivars).select do |e|
				e.match(/^#{Regexp.escape(partial_name)}/)
			end.map do |e|
				(pre || '') + e
			end
		end

		# Try to do tab completion on dir square brackets and slash accessors.
		#
		# Example:
		#
		# dir['subd    # presing tab here will produce dir['subdir/ if subdir exists
		# dir/'subd    # presing tab here will produce dir/'subdir/ if subdir exists
		#
		# This isn't that cool yet, because it can't do multiple levels of subdirs.
		# It does work remotely, though, which is pretty sweet.
		def completion_proc
			proc do |input|
				receiver, accessor, *rest = path_parts(input)
				if receiver
					case accessor
					when /^[\[\/]$/
						complete_path(receiver, accessor, *rest)
					when /^\.$/
						complete_method(receiver, accessor, *rest)
					when nil
						complete_variable(receiver, *rest)
					end
				end
			end
		end
	end
end
