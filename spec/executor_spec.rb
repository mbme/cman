require 'spec_helper'

describe Cman::Executor do
  include FakeFS::SpecHelpers
  before :each do
    FileUtils.mkdir_p BASE_DIR
    @repo_name = 'i3'
  end

  def opts
    { '<repository>' =>  @repo_name,
      '<files>' => [],
      '<record_ids>' => []
    }
  end

  def opts_empty
    res = opts
    res['<repository>'] = nil
    res
  end

  def opts_files(*files)
    res = opts
    res['<files>'].push(*files)
    res
  end

  def opts_ids(*ids)
    res = opts
    res['<record_ids>'].push(*ids)
    res
  end

  def new(command, mock)
    comm = Cman::Executor.new command
    $stdin.should_receive(:gets).and_return('y') if mock
    comm
  end

  def new_add(mock: true)
    new 'add', mock
  end

  def init
    new_add.execute opts
  end

  def new_remove(mock: true)
    new 'remove', mock
  end

  def new_stats
    new 'stats', false
  end

  def new_install(mock: true)
    new 'install', mock
  end

  def new_uninstall(mock: true)
    new 'uninstall', mock
  end

  it 'instantiates with correct command' do
    command = Cman::Executor::COMMANDS[0]
    expect { new command, false }.not_to raise_error
  end

  it 'raise error on incorrect command' do
    expect { new 'status123123', false }.to raise_error
  end

  it 'raise error on wrong number of arguments' do
    expect { new_add(false).execute }.to raise_error
  end

  it 'can add repository' do
    init

    path = File.join(BASE_DIR, @repo_name)
    Dir.exist?(path).should be_true
  end

  it 'cannot add repository second time' do
    init
    expect { init }.to raise_error
  end

  it 'can add files to the repository' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    file3 = '/test/file3'
    touch file1, file3

    new_add.execute opts_files file1, file2, file3, file1

    path = Pathname(File.join(BASE_DIR, @repo_name))

    # we have repo config there, that's why we expect 3
    path.children.length.should eq 3
  end

  it 'cannot add files to unknown repository' do
    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    expect { new_add(false).execute @repo_name, file1, file2 }
      .to raise_error
  end

  it 'can remove repository' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts_ids '0'

    File.symlink?(file1).should be_true

    new_remove.execute opts

    File.symlink?(file1).should be_false
    Dir.exist?(File.join(BASE_DIR, @repo_name)).should be_false
  end

  it 'cannot remove repository if it does not exist' do
    expect { new_remove.execute opts }.to raise_error
  end

  it 'can remove repository files' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2
    new_install.execute opts_ids '1'
    File.symlink?(file2).should be_true

    new_remove.execute opts_ids '1', 'test' # 1 is repo file id
    File.symlink?(file2).should be_false

    path = Pathname(File.join(BASE_DIR, @repo_name))

    path.children.length.should eq 2
  end

  it 'can show stats' do
    init

    new_stats.execute opts_empty

    new_stats.execute opts
  end

  it 'show stats for non existing repo' do
    new_stats.execute opts
  end

  it 'can install files' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts_ids '1'

    File.symlink?(file2).should be_true
  end

  it 'cannot install file if already installed' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts_ids '1'
    new_install.execute opts_ids '1'

    File.symlink?(file2).should be_true
  end

  it 'can install repository' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts

    File.symlink?(file1).should be_true
    File.symlink?(file2).should be_true
  end

  it 'cannot install files from unknown repo' do
    expect { new_install(false).execute opts_ids '1' }.to raise_error
  end

  it 'can uninstall files' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts_ids '1'
    new_uninstall.execute opts_ids '1'

    File.symlink?(file2).should be_false
  end

  it 'can uninstall repo' do
    init

    file1 = '/test/file1'
    file2 = '/test/file2'
    touch file1, file2

    new_add.execute opts_files file1, file2

    new_install.execute opts
    new_uninstall.execute opts

    File.symlink?(file1).should be_false
    File.symlink?(file2).should be_false
  end
end
