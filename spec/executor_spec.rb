require 'spec_helper'

describe Cman::Executor do
  include FakeFS::SpecHelpers
  before :each do
    FileUtils.mkdir_p BASE_DIR
  end

  def new(command)
    Cman::Executor.new command
  end

  it 'instantiates with correct command' do
    command = Cman::Executor::COMMANDS[0]
    expect { new command }.not_to raise_error
  end

  it 'raise error on incorrect command' do
    expect { new 'status123123' }.to raise_error
  end

  it 'raise error on wrong number of arguments' do
    comm = new 'add'
    expect { comm.execute }.to raise_error
  end

  it 'can add repository' do
    comm = new 'add'

    repo_name = 'i3'

    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    path = File.join(BASE_DIR, repo_name)
    Dir.exist?(path).should be_true
  end

  it 'cannot add repository second time' do
    comm = new 'add'

    repo_name = 'i3'

    comm.should_receive(:gets).and_return('y', 'y')

    comm.execute repo_name
    expect { comm.execute repo_name }.to raise_error
  end

  it 'can add files to the repository' do
    repo_name = 'i3'

    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    file1 = '/test/file1'
    file2 = '/test/file2'
    file3 = '/test/file3'
    touch file1, file3

    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, file1, file2, file3, file1

    path = Pathname(File.join(BASE_DIR, repo_name))

    # we have repo config there, that's why we expect 3
    path.children.length.should eq 3
  end

  it 'cannot add files to unknown repository' do
    repo_name = 'i3'

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    comm = new 'add'
    expect { comm.execute repo_name, file1, file2 }
      .to raise_error
  end

  it 'can remove repository' do
    repo_name = 'i3'

    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    comm = new 'remove'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    path = File.join(BASE_DIR, repo_name)
    Dir.exist?(path).should be_false
  end

  it 'cannot remove repository if it does not exist' do
    repo_name = 'i3'

    comm = new 'remove'
    comm.should_receive(:gets).and_return('y')
    expect { comm.execute repo_name }.to raise_error
  end

  it 'can remove repository files' do
    repo_name = 'i3'

    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, file1, file2

    comm = new 'remove'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, '1', 'test' # 1 is repo file id

    path = Pathname(File.join(BASE_DIR, repo_name))

    path.children.length.should eq 2
  end

  it 'can show stats' do
    repo_name = 'i3'
    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    comm = new 'stats'
    comm.execute

    comm.execute repo_name
  end

  it 'show stats for non existing repo' do
    repo_name = 'i3'

    comm = new 'stats'
    comm.execute repo_name
  end

  it 'can install files' do
    repo_name = 'i3'

    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, file1, file2

    comm = new 'install'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, '1'

    File.symlink?(file2).should be_true
  end

  it 'can install repository' do
    repo_name = 'i3'

    comm = new 'add'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name, file1, file2

    comm = new 'install'
    comm.should_receive(:gets).and_return('y')
    comm.execute repo_name

    File.symlink?(file1).should be_true
    File.symlink?(file2).should be_true
  end

  it 'cannot install files from unknown repo' do
    repo_name = 'i3'

    comm = new 'install'
    expect { comm.execute repo_name, '1' }.to raise_error
  end
end
