require 'spec_helper'

describe Cman::Record do
  def new(path)
    Cman::Record.new path
  end

  it 'simplifies path' do
    name = 'testfile'

    file = File.join Dir.home, name
    rec = new file

    rec.path.should eq "~/#{name}"
  end
end
