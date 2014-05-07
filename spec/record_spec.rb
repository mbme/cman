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

    file = "/other/#{name}"
    rec = new file

    rec.path.should eq file
  end

  it 'eq by path' do
    file = '/test/otherfile'
    rec1 = new file
    rec2 = new file

    rec1.should eq rec2
  end
end
