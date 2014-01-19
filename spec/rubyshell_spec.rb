require File.dirname(__FILE__) + '/base'

describe RubyShell do
	it "fetches a local file path" do
		RubyShell['/etc/hosts'].full_path.should == '/etc/hosts'
	end

	it "fetches the dir of __FILE__" do
		RubyShell.dir(__FILE__).name.should == 'spec'
	end

	it "fetches the launch dir (aka current working directory or pwd)" do
		Dir.stub!(:pwd).and_return('/tmp')
		RubyShell.launch_dir.should == RubyShell::Box.new['/tmp/']
	end

	it "runs a bash command" do
		RubyShell.bash('echo hi').should == "hi\n"
	end

	it "gets the list of local processes" do
		RubyShell.processes.should be_kind_of(RubyShell::ProcessSet)
	end

	it "gets my process" do
		RubyShell.my_process.pid.should == Process.pid
	end
end
