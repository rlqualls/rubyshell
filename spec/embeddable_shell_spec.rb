require File.dirname(__FILE__) + '/base'

describe RubyShell::EmbeddableShell do
  before do
    @shell = RubyShell::EmbeddableShell.new
  end

  it "should execute unknown methods against a RubyShell::Shell instance" do
    @shell.root.class.should == RubyShell::Dir
  end
  
  it "should executes a block as if it were inside the shell" do
    @shell.execute_in_shell {
      root.class.should == RubyShell::Dir
    }
  end
end
