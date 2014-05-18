require 'spec_helper'

describe Cman::Record do
  include FakeFS::SpecHelpers
  before :each do
    FileUtils.mkdir_p BASE_DIR
  end

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

  it 'correctly builds backup path' do
    file1 = '/test/file'
    file2 = '/test/.file'
    backup_file = ".#{File.basename file1}#{Cman::BACKUP_EXT}"

    rec = new file1
    File.basename(rec.backup_path).should eq backup_file

    rec = new file2
    File.basename(rec.backup_path).should eq backup_file
  end

  it 'can be installed' do
    repo = Cman::Repository.new 'i3'
    repo.create

    file = '/some/file'
    touch file

    rec = repo.add_record file
    rec.installed?.should be_false

    rec.install

    rec.installed?.should be_true
    File.exist?(rec.backup_path).should be_true
  end

  it 'can be installed if is dir' do
    repo = Cman::Repository.new 'i3'
    repo.create

    dir = '/some/dir'
    file = "#{dir}/file"
    touch file

    rec = repo.add_record dir
    rec.installed?.should be_false

    rec.install

    rec.installed?.should be_true
    File.exist?(rec.backup_path).should be_true
  end

  it 'cannot be installed if already installed' do
    repo = Cman::Repository.new 'i3'
    repo.create

    file = '/some/file'
    touch file

    rec = repo.add_record file
    rec.install
    rec.installed?.should be_true

    expect { rec.install }.to raise_error
  end

  it 'can be uninstalled' do
    repo = Cman::Repository.new 'i3'
    repo.create

    file = '/some/file'
    touch file

    rec = repo.add_record file
    rec.install
    rec.installed?.should be_true
    File.exist?(rec.backup_path).should be_true

    rec.uninstall
    rec.installed?.should be_false

    # check if backup file restored
    File.exist?(rec.backup_path).should be_false
    File.exist?(rec.path).should be_true
  end

  it 'cannot be uninstalled if not installed' do
    repo = Cman::Repository.new 'i3'
    repo.create

    file = '/some/file'
    touch file

    rec = repo.add_record file
    rec.installed?.should be_false
    File.exist?(rec.backup_path).should be_false

    expect { rec.uninstall }.to raise_error
  end
end
